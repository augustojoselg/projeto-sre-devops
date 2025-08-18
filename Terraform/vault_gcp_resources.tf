# 1. Bucket no Google Cloud Storage para o backend do Vault
resource "google_storage_bucket" "vault_storage" {
  name                        = "${var.project_id}-vault-storage"
  location                    = var.region
  force_destroy               = true # Apenas para facilitar a limpeza em ambientes de teste. Remova em produção crítica.
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

# 2. Chave no Google KMS para o Auto-Unseal do Vault
# O Key Ring já foi criado em main.tf, vamos reutilizá-lo.
resource "google_kms_crypto_key" "vault_unseal" {
  name     = "vault-unseal-key"
  key_ring = data.google_kms_key_ring.existing_keyring.name == "gke-keyring" ? data.google_kms_key_ring.existing_keyring.id : google_kms_key_ring.keyring[0].id
  purpose  = "ENCRYPT_DECRYPT"
}

# 3. Conta de Serviço do Google (GSA) para o Vault
resource "google_service_account" "vault" {
  account_id   = "vault-server"
  display_name = "Vault Server Service Account"
  project      = var.project_id
}

# 4. Permissões para a GSA do Vault
# Permissão para acessar o bucket de storage
resource "google_storage_bucket_iam_member" "vault_storage_access" {
  bucket = google_storage_bucket.vault_storage.name
  role   = "roles/storage.objectAdmin"
  member = google_service_account.vault.member
}

# Permissão para usar a chave KMS
resource "google_kms_crypto_key_iam_member" "vault_kms_access" {
  crypto_key_id = google_kms_crypto_key.vault_unseal.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = google_service_account.vault.member
}

# 5. Vínculo entre a Conta de Serviço do Kubernetes (KSA) e a GSA do Google
# Isso permite que o pod do Vault no GKE se autentique como a GSA que criamos.
resource "google_service_account_iam_member" "vault_ksa_binding" {
  service_account_id = google_service_account.vault.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[vault/vault]"
}
