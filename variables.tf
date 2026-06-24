variable "folder_id" {
  type = string
}

variable "name" {
  type        = string
  description = "Name of gitlab-runner"
}

variable "ns_labels" {
  type        = map(string)
  description = "Map with labels for k8s namespace"
  default     = {}
}

variable "custom_helm_values" {
  type        = string
  default     = ""
  description = "Custom YAML helm values"
}

variable "sa_prefix" {
  type        = string
  description = "Prefix for ServiceAccount"
  default     = "k8s"
}

variable "cluster_secret_store_yandexlockbox" {
  type        = bool
  description = "Create ClusterSecretStore for yandexlockbox"
  default     = false
}

variable "cluster_secret_store_yandexcertificate" {
  type        = bool
  description = "Create ClusterSecretStore for yandexlockbox"
  default     = false
}

variable "cluster_secret_store_vault_approle" {
  type = map(object({
    server      = string,
    auth_path   = string,
    namespace   = string,
    role_name   = string,
    role_key    = string,
    secret_name = string,
    secret_key  = string
  }))
  description = "params ClusterSecretStore for valut auth appRole"
  default     = {}
}