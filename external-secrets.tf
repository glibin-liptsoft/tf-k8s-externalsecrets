resource "kubernetes_namespace" "this" {
  metadata {
    name   = var.name
    labels = var.ns_labels
  }
}

resource "helm_release" "this" {
  name      = var.name
  chart     = "${path.module}/helm-chart"
  namespace = var.name

  values = [
    try(var.custom_helm_values),
  ]
  set_sensitive = [
    {
      name  = "auth.json"
      value = var.cluster_secret_store_yandexlockbox == false || var.cluster_secret_store_yandexcertificate == false ? "none" : "${base64encode(local.service_account_key)}"
    }
  ]

  depends_on = [
    kubernetes_namespace.this,
    yandex_iam_service_account.default
  ]
}

resource "time_sleep" "wait_10_seconds" {
  create_duration = "10s"
  depends_on = [
    kubernetes_namespace.this,
    yandex_iam_service_account.default,
    helm_release.this
  ]
}

resource "kubernetes_manifest" "cluster_secret_store_yandexlockbox" {
  count = var.cluster_secret_store_yandexlockbox != false ? 1 : 0
  depends_on = [
    kubernetes_namespace.this,
    yandex_iam_service_account.default,
    helm_release.this,
    time_sleep.wait_10_seconds
  ]
  manifest = {
    "apiVersion" = "external-secrets.io/v1beta1"
    "kind"       = "ClusterSecretStore"
    "metadata" = {
      "name" = "secret-store-yandexlockbox"
    }
    "spec" = {
      "provider" = {
        "yandexlockbox" = {
          "auth" = {
            "authorizedKeySecretRef" = {
              "namespace" = "${var.name}"
              "name"      = "sa-creds"
              "key"       = "key"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "cluster_secret_store_yandexcertificatemanager" {
  count = var.cluster_secret_store_yandexcertificate != false ? 1 : 0
  depends_on = [
    kubernetes_namespace.this,
    yandex_iam_service_account.default,
    helm_release.this,
    time_sleep.wait_10_seconds
  ]
  manifest = {
    "apiVersion" = "external-secrets.io/v1beta1"
    "kind"       = "ClusterSecretStore"
    "metadata" = {
      "name" = "secret-store-yandexcertificatemanager"
    }
    "spec" = {
      "provider" = {
        "yandexcertificatemanager" = {
          "auth" = {
            "authorizedKeySecretRef" = {
              "namespace" = "${var.name}"
              "name"      = "sa-creds"
              "key"       = "key"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "cluster_secret_store_vault_approle" {
  for_each = var.cluster_secret_store_vault_approle
  depends_on = [
    kubernetes_namespace.this,
    yandex_iam_service_account.default,
    helm_release.this,
    time_sleep.wait_10_seconds
  ]
  manifest = {
    "apiVersion" = "external-secrets.io/v1beta1"
    "kind"       = "ClusterSecretStore"
    "metadata" = {
      "name" = "secret-store-vault-${each.key}-approle"
    }
    "spec" = {
      "provider" = {
        "vault" = {
          "server" = "${each.value.server}"
          "path"   = "${each.key}"
          "auth" = {
            "appRole" = {
              "path" = "${each.value.auth_path}"
              "roleRef" = {
                "namespace" = "${each.value.namespace}"
                "name"      = "${each.value.role_name}"
                "key"       = "${each.value.role_key}"
              }
              "secretRef" = {
                "namespace" = "${each.value.namespace}"
                "name"      = "${each.value.secret_name}"
                "key"       = "${each.value.secret_key}"
              }
            }
          }
        }
      }
    }
  }
}