# Associação de Contas de Serviço às APIs
# Este arquivo garante que as contas de serviço tenham acesso às APIs habilitadas

# Referências para as contas de serviço dos módulos
locals {
  devops_sa_email   = module.service_account.devops_email
  gke_node_sa_email = data.google_service_account.gke_node.email
}

# 1. Conta DevOps - Acesso completo às APIs
resource "google_project_iam_member" "devops_api_access" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "cloudbuild.googleapis.com",
    "run.googleapis.com",
    "cloudkms.googleapis.com",
    "dns.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ])

  project = var.project_id
  role    = "roles/servicemanagement.serviceController"
  member  = "serviceAccount:${local.devops_sa_email}"
}

# 2. Conta GKE Node - Acesso específico para operações do cluster
resource "google_project_iam_member" "gke_node_api_access" {
  for_each = toset([
    "compute.googleapis.com",   # Para criar/gerenciar VMs
    "container.googleapis.com", # Para operações GKE
    "storage.googleapis.com",   # Para pull de imagens
    "logging.googleapis.com",   # Para logs do cluster
    "monitoring.googleapis.com" # Para métricas do cluster
  ])

  project = var.project_id
  role    = "roles/servicemanagement.serviceController"
  member  = "serviceAccount:${local.gke_node_sa_email}"
}

# 3. Permissões específicas para Cloud Build
resource "google_project_iam_member" "devops_cloudbuild" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${local.devops_sa_email}"
}

# 4. Permissões específicas para Cloud Run
resource "google_project_iam_member" "devops_cloudrun" {
  project = var.project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${local.devops_sa_email}"
}

# 5. Permissões específicas para Cloud KMS
resource "google_project_iam_member" "devops_kms" {
  project = var.project_id
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member  = "serviceAccount:${local.devops_sa_email}"
}

# 6. Permissões específicas para DNS
resource "google_project_iam_member" "devops_dns" {
  project = var.project_id
  role    = "roles/dns.admin"
  member  = "serviceAccount:${local.devops_sa_email}"
}

# 7. Permissões específicas para Monitoring
resource "google_project_iam_member" "devops_monitoring" {
  project = var.project_id
  role    = "roles/monitoring.admin"
  member  = "serviceAccount:${local.devops_sa_email}"
}

# 8. Permissões específicas para Logging
resource "google_project_iam_member" "devops_logging" {
  project = var.project_id
  role    = "roles/logging.admin"
  member  = "serviceAccount:${local.devops_sa_email}"
}

# Dependências para garantir ordem correta
# Nota: As dependências são gerenciadas automaticamente pelo Terraform
# baseado nas referências entre recursos
