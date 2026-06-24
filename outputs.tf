output "namespace" {
  value = var.name
}

output "acount_key" {
  sensitive = true
  value     = local.service_account_key
}

output "lockbox_secretStore_name" {
  value = var.cluster_secret_store_yandexlockbox == false ? "false" : kubernetes_manifest.cluster_secret_store_yandexlockbox[0].manifest.metadata.name
}

output "certificate_secretStore_name" {
  value = var.cluster_secret_store_yandexcertificate == false ? "false" : kubernetes_manifest.cluster_secret_store_yandexcertificatemanager[0].manifest.metadata.name
}

output "vault_approle_secretStore_name" {
  value = length(var.cluster_secret_store_vault_approle) == 0 ? {} : { for name, key in kubernetes_manifest.cluster_secret_store_vault_approle : "mount ${name}" => "secret-store-vault-${name}-approle" }
}

# output "yandex_lockbox" {
#   value = var.cluster_secret_store_yandexlockbox == null ? "false" : "true"
# }

# output "yandex_certificate" {
#   value = var.cluster_secret_store_yandexcertificate == null ? "false" : "true"
# }

# output "vault_approle" {
#   value = length(var.cluster_secret_store_vault_approle) > 0 ? "false" : "true"
# }