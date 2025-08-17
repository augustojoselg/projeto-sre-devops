provider "google" {
  project = var.project_id
  region  = var.region
}

# 1️⃣ Criar Service Account
resource "google_service_account" "devops" {
  account_id   = "devops-sre"
  display_name = "Service Account DevOps"
}

# 2️⃣ Papéis (roles) necessários
locals {
  devops_roles = [
    "roles/viewer",
    "roles/editor",
    "roles/compute.networkAdmin",
    "roles/compute.admin",
    "roles/storage.admin",
    "roles/container.admin",
    "roles/cloudsql.admin",
    "roles/iam.serviceAccountAdmin",    # opcional
    "roles/iam.serviceAccountKeyAdmin",  # opcional
    "roles/iam.serviceAccountUser",      # opcional
    # Permissões específicas para APIs
    "roles/cloudbuild.builds.builder",   # Cloud Build
    "roles/run.developer",               # Cloud Run
    "roles/cloudkms.cryptoKeyEncrypterDecrypter", # Cloud KMS
    "roles/dns.admin",                   # Cloud DNS
    "roles/monitoring.admin",            # Cloud Monitoring
    "roles/logging.admin",               # Cloud Logging
    "roles/resourcemanager.projectIamAdmin" # Resource Manager
  ]
}

# 3️⃣ Atribuir permissões à conta de serviço
resource "google_project_iam_member" "devops_bindings" {
  for_each = toset(local.devops_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.devops.email}"
}

# 4️⃣ Gerar chave JSON
resource "google_service_account_key" "devops_key" {
  service_account_id = google_service_account.devops.name
}

# 5️⃣ Salvar chave localmente
resource "local_file" "devops_key_file" {
  content  = base64decode(google_service_account_key.devops_key.private_key)
  filename = "${path.module}/devops-sre-key.json"
}
