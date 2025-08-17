# Pipeline CI/CD com Cloud Build

# IMPORTANTE: Este arquivo será descomentado após o cluster GKE estar ativo
# Execute: terraform apply para criar apenas a infraestrutura básica
# Depois: Descomente este arquivo e execute novamente para criar os recursos Kubernetes

# 1. Cloud Build Trigger para aplicação principal
resource "google_cloudbuild_trigger" "app_trigger" {
  name        = "app-build-trigger"
  description = "Trigger para build e deploy de aplicações"
  project     = var.project_id
  location    = "global" # Especificar a location global explicitamente

  github {
    owner = var.github_owner
    name  = var.github_repo
    push {
      branch = "^main$" # Usar expressão regular para o branch
    }
  }

  filename = "cloudbuild.yaml"

  substitutions = {
    _CLUSTER_NAME  = data.google_container_cluster.existing_cluster.name == "${var.project_id}-cluster" ? data.google_container_cluster.existing_cluster.name : google_container_cluster.primary[0].name
    _ZONE          = var.zone
    _PROJECT_ID    = var.project_id
    _REGION        = var.region
    _DEVOPS_DOMAIN = var.devops_domain
    _SRE_DOMAIN    = var.sre_domain
  }

  # Tornar reutilizável
  lifecycle {
    create_before_destroy = true
  }
}

# 2. Cloud Build Trigger para infraestrutura
# COMENTADO - será habilitado após cluster estar ativo
# resource "google_cloudbuild_trigger" "infra_trigger" {
#   name        = "infra-build-trigger"
#   description = "Trigger para build da infraestrutura"
#   project     = var.project_id
#   
#   github {
#     owner  = var.github_owner
#     name   = "projeto-sre-devops"
#     push {
#       branch = "infra"
#     }
#   }
#   
#   filename = "cloudbuild-infra.yaml"
#   
#   substitutions = {
#     _CLUSTER_NAME = google_container_cluster.primary.name
#     _ZONE         = var.zone
#     _PROJECT_ID   = var.project_id
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 3. Cloud Build Trigger para monitoramento
# COMENTADO - será habilitado após cluster estar ativo
# resource "google_cloudbuild_trigger" "monitoring_trigger" {
#   name        = "monitoring-build-trigger"
#   description = "Trigger para build dos componentes de monitoramento"
#   project     = var.project_id
#   
#   github {
#     owner  = var.github_owner
#     name   = "projeto-sre-devops"
#     push {
#       branch = "monitoring"
#     }
#   }
#   
#   filename = "cloudbuild-monitoring.yaml"
#   
#   substitutions = {
#     _CLUSTER_NAME = google_container_cluster.primary.name
#     _ZONE         = var.zone
#     _PROJECT_ID   = var.project_id
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 4. Cloud Build Trigger para testes
# COMENTADO - será habilitado após cluster estar ativo
# resource "google_cloudbuild_trigger" "test_trigger" {
#   name        = "test-build-trigger"
#   description = "Trigger para execução de testes automatizados"
#   project     = var.project_id
#   
#   github {
#     owner  = var.github_owner
#     name   = "projeto-sre-devops"
#     push {
#       branch = "test"
#     }
#   }
#   
#   filename = "cloudbuild-test.yaml"
#   
#   substitutions = {
#     _CLUSTER_NAME = google_container_cluster.primary.name
#     _ZONE         = var.zone
#     _PROJECT_ID   = var.project_id
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 5. Cloud Build Trigger para deploy automático
# COMENTADO - será habilitado após cluster estar ativo
# resource "google_cloudbuild_trigger" "deploy_trigger" {
#   name        = "deploy-trigger"
#   description = "Trigger para deploy automático após build bem-sucedido"
#   project     = var.project_id
#   
#   github {
#     owner  = var.github_owner
#     name   = "projeto-sre-devops"
#     push {
#       branch = "deploy"
#     }
#   }
#   
#   filename = "cloudbuild-deploy.yaml"
#   
#   substitutions = {
#     _CLUSTER_NAME = google_container_cluster.primary.name
#     _ZONE         = var.zone
#     _PROJECT_ID   = var.project_id
#     _NAMESPACE    = "default"
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 6. Cloud Build Trigger para rollback
# COMENTADO - será habilitado após cluster estar ativo
# resource "google_cloudbuild_trigger" "rollback_trigger" {
#   name        = "rollback-trigger"
#   description = "Trigger para rollback em caso de falha"
#   project     = var.project_id
#   
#   github {
#     owner  = var.github_owner
#     name   = "projeto-sre-devops"
#     push {
#       branch = "rollback"
#     }
#   }
#   
#   filename = "cloudbuild-rollback.yaml"
#   
#   substitutions = {
#     _CLUSTER_NAME = google_container_cluster.primary.name
#     _ZONE         = var.zone
#     _PROJECT_ID   = var.project_id
#     _NAMESPACE    = "default"
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 7. Cloud Build Trigger para segurança
# COMENTADO - será habilitado após cluster estar ativo
# resource "google_cloudbuild_trigger" "security_trigger" {
#   name        = "security-scan-trigger"
#   description = "Trigger para escaneamento de segurança"
#   project     = var.project_id
#   
#   github {
#     owner  = var.github_owner
#     name   = "projeto-sre-devops"
#     push {
#       branch = "security"
#     }
#   }
#   
#   filename = "cloudbuild-security.yaml"
#   
#   substitutions = {
#     _CLUSTER_NAME = google_container_cluster.primary.name
#     _ZONE         = var.zone
#     _PROJECT_ID   = var.project_id
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 8. Cloud Build Trigger para backup
# COMENTADO - será habilitado após cluster estar ativo
# resource "google_cloudbuild_trigger" "backup_trigger" {
#   name        = "backup-trigger"
#   description = "Trigger para backup automático dos dados"
#   project     = var.project_id
#   
#   github {
#     owner  = var.github_owner
#     name   = "projeto-sre-devops"
#     push {
#       branch = "backup"
#     }
#   }
#   
#   filename = "cloudbuild-backup.yaml"
#   
#   substitutions = {
#     _CLUSTER_NAME = google_container_cluster.primary.name
#     _ZONE         = var.zone
#     _PROJECT_ID   = var.project_id
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 9. Cloud Build Trigger para limpeza
# COMENTADO - será habilitado após cluster estar ativo
# resource "google_cloudbuild_trigger" "cleanup_trigger" {
#   name        = "cleanup-trigger"
#   description = "Trigger para limpeza automática de recursos"
#   project     = var.project_id
#   
#   github {
#     owner  = var.github_owner
#     name   = "projeto-sre-devops"
#     push {
#       branch = "cleanup"
#     }
#   }
#   
#   filename = "cloudbuild-cleanup.yaml"
#   
#   substitutions = {
#     _CLUSTER_NAME = google_container_cluster.primary.name
#     _ZONE         = var.zone
#     _PROJECT_ID   = var.project_id
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 10. Cloud Build Trigger para monitoramento de performance
# COMENTADO - será habilitado após cluster estar ativo
# resource "google_cloudbuild_trigger" "performance_trigger" {
#   name        = "performance-test-trigger"
#   description = "Trigger para testes de performance automatizados"
#   project     = var.project_id
#   
#   github {
#     owner  = var.github_owner
#     name   = "projeto-sre-devops"
#     push {
#       branch = "performance"
#     }
#   }
#   
#   filename = "cloudbuild-performance.yaml"
#   
#   substitutions = {
#     _CLUSTER_NAME = google_container_cluster.primary.name
#     _ZONE         = var.zone
#     _PROJECT_ID   = var.project_id
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# IMPORTANTE: Este arquivo será descomentado após o cluster GKE estar ativo
# Execute: terraform apply para criar apenas a infraestrutura básica
# Depois: Descomente este arquivo e execute novamente para criar os recursos Kubernetes






























