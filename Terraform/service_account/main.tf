provider "google" {
  project = var.project_id
  region  = var.region
}

# Verifica se a conta de serviço já existe
data "google_service_account" "existing_devops_sa" {
  account_id = "devops-sre"
  project    = var.project_id
}

# Cria a conta de serviço apenas se ela não existir
resource "google_service_account" "devops" {
  count = data.google_service_account.existing_devops_sa.email == "" ? 1 : 0

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
  member  = "serviceAccount:${data.google_service_account.existing_devops_sa.email != "" ? data.google_service_account.existing_devops_sa.email : google_service_account.devops[0].email}"
}

# Gera chave para a conta de serviço (opcional, mas necessário para o output)
resource "google_service_account_key" "devops_key" {
  service_account_id = data.google_service_account.existing_devops_sa.email != "" ? data.google_service_account.existing_devops_sa.name : google_service_account.devops[0].name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

# 5️⃣ Salvar chave localmente
resource "local_file" "devops_key_file" {
  content  = base64decode(google_service_account_key.devops_key.private_key)
  filename = "${path.module}/devops-sre-key.json"
}
