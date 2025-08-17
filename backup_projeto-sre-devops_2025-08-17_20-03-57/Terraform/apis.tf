# APIs do Google Cloud necessárias para o projeto

# 1. Compute Engine API
resource "google_project_service" "compute" {
  service                    = "compute.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

# 2. Container API (GKE)
resource "google_project_service" "container" {
  service                    = "container.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

# 3. Cloud Build API
resource "google_project_service" "cloudbuild" {
  service                    = "cloudbuild.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

# 4. Cloud Run API
resource "google_project_service" "run" {
  service                    = "run.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

# 5. Cloud KMS API
resource "google_project_service" "kms" {
  service                    = "cloudkms.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

# 6. Cloud DNS API
resource "google_project_service" "dns" {
  service                    = "dns.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

# 7. Cloud Monitoring API
resource "google_project_service" "monitoring" {
  service                    = "monitoring.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

# 8. Cloud Logging API
resource "google_project_service" "logging" {
  service                    = "logging.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

# 9. IAM API
resource "google_project_service" "iam" {
  service                    = "iam.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

# 10. Resource Manager API
resource "google_project_service" "resourcemanager" {
  service                    = "cloudresourcemanager.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

# 11. Storage API
resource "google_project_service" "storage" {
  service                    = "storage.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

# 12. Secret Manager API
resource "google_project_service" "secretmanager" {
  service                    = "secretmanager.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}
