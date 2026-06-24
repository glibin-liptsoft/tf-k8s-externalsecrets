resource "yandex_iam_service_account" "default" {
  count       = var.cluster_secret_store_yandexlockbox != false || var.cluster_secret_store_yandexcertificate != false ? 1 : 0
  name        = "${var.sa_prefix}-externalsecret"
  description = "sa for extarnal secret operator in k8s cluster"
  folder_id   = var.folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "lockbox-editor" {
  count     = var.cluster_secret_store_yandexlockbox != false ? 1 : 0
  folder_id = var.folder_id
  member    = "serviceAccount:${yandex_iam_service_account.default[count.index].id}"
  role      = "lockbox.editor"
}

resource "yandex_resourcemanager_folder_iam_member" "lockbox-payloadviewer" {
  count     = var.cluster_secret_store_yandexlockbox != false ? 1 : 0
  folder_id = var.folder_id
  member    = "serviceAccount:${yandex_iam_service_account.default[count.index].id}"
  role      = "lockbox.payloadViewer"
}

resource "yandex_resourcemanager_folder_iam_member" "certificates-downloader" {
  count     = var.cluster_secret_store_yandexcertificate != false ? 1 : 0
  folder_id = var.folder_id
  member    = "serviceAccount:${yandex_iam_service_account.default[count.index].id}"
  role      = "certificate-manager.certificates.downloader"
}

resource "yandex_iam_service_account_key" "default" {
  count              = var.cluster_secret_store_yandexlockbox != false || var.cluster_secret_store_yandexcertificate != false ? 1 : 0
  service_account_id = yandex_iam_service_account.default[count.index].id

  description   = "key for access certificate in yandex cloud"
  key_algorithm = "RSA_4096"
}

locals {
  service_account_key = var.cluster_secret_store_yandexlockbox == false || var.cluster_secret_store_yandexcertificate == false ? null : jsonencode({
    created_at         = yandex_iam_service_account_key.default[0].created_at
    id                 = yandex_iam_service_account_key.default[0].id
    key_algorithm      = yandex_iam_service_account_key.default[0].key_algorithm
    private_key        = yandex_iam_service_account_key.default[0].private_key
    public_key         = yandex_iam_service_account_key.default[0].public_key
    service_account_id = yandex_iam_service_account_key.default[0].service_account_id
  })
}

