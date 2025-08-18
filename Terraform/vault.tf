# 1. Namespace para o Vault
resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
  }
}

# 2. Instalação do HashiCorp Vault via Helm
resource "helm_release" "vault" {
  count      = var.destroy_vault_release ? 0 : 1
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace  = kubernetes_namespace.vault.metadata[0].name
  version    = "0.27.0" # Versão estável e compatível

  # Renderiza o arquivo de valores do Vault como um template
  values = [
    templatefile("${path.module}/vault-values.yaml.tpl", {
      gcp_project_id       = var.project_id
      gcp_region           = var.region
      vault_storage_bucket = google_storage_bucket.vault_storage.name
      kms_key_ring         = data.google_kms_key_ring.existing_keyring.name == "gke-keyring" ? data.google_kms_key_ring.existing_keyring.name : google_kms_key_ring.keyring[0].name
      kms_crypto_key       = google_kms_crypto_key.vault_unseal.name
      vault_gcp_sa_email   = google_service_account.vault.email
    })
  ]

  depends_on = [
    kubernetes_namespace.vault
  ]
}
