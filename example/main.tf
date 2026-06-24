module "iam_accounts" {
  source    = "../"
  folder_id = "1234567890"

  name = "external-secret"
  # create ClusterSecretStore with provider yandexlockbox
  cluster_secret_store_yandexlockbox = true
  # create ClusterSecretStore with provider yandexcertificatemanager
  cluster_secret_store_yandexcertificate = true
  # create ClusterSecretStore with provider vault and auth approle
  cluster_secret_store_vault_approle = {
    # name - path mount secrets engines in vault
    devops = {
      # vault url
      server = "https://vault.infra.lipt-soft.ru"
      # path auth appRole
      auth_path = "approle"
      # namespace with secret
      namespace = "external-secret"
      # name secret with roleId
      role_name = "vault-roleapp"
      # key with roleId
      role_key = "roleid"
      # name secret with secretId
      secret_name = "vault-roleapp"
      # key with secretId
      secret_key = "secretid"
    }
  }
}