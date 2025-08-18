provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_service_account" "devops" {
  project      = var.project_id
  account_id   = "devops-sre"
  display_name = "Service Account DevOps"
  description  = "Conta de serviço para pipeline CI/CD e acesso ao GKE"
}

# Associa papéis IAM à conta de serviço
resource "google_project_iam_member" "devops_roles" {
  for_each = toset([
    "roles/container.admin",
    "roles/storage.admin",
    "roles/cloudbuild.builds.editor",
    "roles/iam.serviceAccountUser",
    "roles/cloudkms.admin"
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.devops.email}"
}

# Gera chave para a conta de serviço
resource "google_service_account_key" "devops_key" {
  service_account_id = google_service_account.devops.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

# Salvar chave localmente
resource "local_file" "devops_key_file" {
  content  = base64decode(google_service_account_key.devops_key.private_key)
  filename = "${path.module}/devops-sre-key.json"
}
