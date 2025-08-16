# Configuração de CI/CD e Pipeline

# 1. Cloud Build para automação da infraestrutura
resource "google_cloudbuild_trigger" "infrastructure_deploy" {
  name        = "infrastructure-deploy"
  description = "Trigger para deploy da infraestrutura via Terraform"
  
  github {
    owner  = var.github_owner
    name   = var.github_repo
    push {
      branch = "main"
      include_logs = true
    }
  }
  
  filename = "cloudbuild-infrastructure.yaml"
  
  substitutions = {
    _CLUSTER_NAME = google_container_cluster.primary.name
    _PROJECT_ID   = var.project_id
    _REGION       = var.region
    _ZONE         = var.zone
  }
  
  depends_on = [google_container_cluster.primary]
}

# 2. Cloud Build para automação das aplicações
resource "google_cloudbuild_trigger" "application_deploy" {
  name        = "application-deploy"
  description = "Trigger para deploy das aplicações Kubernetes"
  
  github {
    owner  = var.github_owner
    name   = var.github_repo
    push {
      branch = "main"
      include_logs = true
    }
  }
  
  filename = "cloudbuild-application.yaml"
  
  substitutions = {
    _CLUSTER_NAME = google_container_cluster.primary.name
    _PROJECT_ID   = var.project_id
    _REGION       = var.region
    _NAMESPACE    = "default"
  }
  
  depends_on = [google_container_cluster.primary]
}

# 3. Cloud Build para automação do monitoramento
resource "google_cloudbuild_trigger" "monitoring_deploy" {
  name        = "monitoring-deploy"
  description = "Trigger para deploy do stack de monitoramento"
  
  github {
    owner  = var.github_owner
    name   = var.github_repo
    push {
      branch = "main"
      include_logs = true
    }
  }
  
  filename = "cloudbuild-monitoring.yaml"
  
  substitutions = {
    _CLUSTER_NAME = google_container_cluster.primary.name
    _PROJECT_ID   = var.project_id
    _REGION       = var.region
  }
  
  depends_on = [google_container_cluster.primary]
}

# 4. Cloud Build para testes de estresse
resource "google_cloudbuild_trigger" "stress_test" {
  name        = "stress-test"
  description = "Trigger para execução de testes de estresse"
  
  github {
    owner  = var.github_owner
    name   = var.github_repo
    push {
      branch = "main"
      include_logs = true
    }
  }
  
  filename = "cloudbuild-stress-test.yaml"
  
  substitutions = {
    _CLUSTER_NAME = google_container_cluster.primary.name
    _PROJECT_ID   = var.project_id
    _REGION       = var.region
    _APP_URL      = "https://${var.domain_name}"
  }
  
  depends_on = [google_container_cluster.primary]
}

# 5. Cloud Build para backup automático
resource "google_cloudbuild_trigger" "backup_automation" {
  name        = "backup-automation"
  description = "Trigger para backup automático do cluster"
  
  github {
    owner  = var.github_owner
    name   = var.github_repo
    push {
      branch = "main"
      include_logs = true
    }
  }
  
  filename = "cloudbuild-backup.yaml"
  
  substitutions = {
    _CLUSTER_NAME = google_container_cluster.primary.name
    _PROJECT_ID   = var.project_id
    _REGION       = var.region
    _BACKUP_BUCKET = google_storage_bucket.backup_bucket.name
  }
  
  depends_on = [google_container_cluster.primary]
}

# 6. Cloud Build para segurança e compliance
resource "google_cloudbuild_trigger" "security_scan" {
  name        = "security-scan"
  description = "Trigger para scan de segurança e compliance"
  
  github {
    owner  = var.github_owner
    name   = var.github_repo
    push {
      branch = "main"
      include_logs = true
    }
  }
  
  filename = "cloudbuild-security.yaml"
  
  substitutions = {
    _CLUSTER_NAME = google_container_cluster.primary.name
    _PROJECT_ID   = var.project_id
    _REGION       = var.region
  }
  
  depends_on = [google_container_cluster.primary]
}

# 7. Cloud Scheduler para execução automática de testes
resource "google_cloud_scheduler_job" "automated_testing" {
  name             = "automated-testing"
  description      = "Job para execução automática de testes"
  schedule         = "0 */6 * * *"  # A cada 6 horas
  time_zone        = "America/Sao_Paulo"
  
  http_target {
    http_method = "POST"
    uri         = "https://cloudbuild.googleapis.com/v1/projects/${var.project_id}/triggers/${google_cloudbuild_trigger.stress_test.trigger_id}:run"
    
    headers = {
      "Content-Type" = "application/json"
      "Authorization" = "Bearer ${data.google_client_config.default.access_token}"
    }
    
    body = base64encode(jsonencode({
      branchName = "main"
    }))
  }
  
  depends_on = [google_cloudbuild_trigger.stress_test]
}

# 8. Cloud Scheduler para backup automático
resource "google_cloud_scheduler_job" "automated_backup" {
  name             = "automated-backup"
  description      = "Job para backup automático"
  schedule         = "0 2 * * *"  # Diariamente às 2h da manhã
  time_zone        = "America/Sao_Paulo"
  
  http_target {
    http_method = "POST"
    uri         = "https://cloudbuild.googleapis.com/v1/projects/${var.project_id}/triggers/${google_cloudbuild_trigger.backup_automation.trigger_id}:run"
    
    headers = {
      "Content-Type" = "application/json"
      "Authorization" = "Bearer ${data.google_client_config.default.access_token}"
    }
    
    body = base64encode(jsonencode({
      branchName = "main"
    }))
  }
  
  depends_on = [google_cloudbuild_trigger.backup_automation]
}

# 9. Cloud Scheduler para scan de segurança
resource "google_cloud_scheduler_job" "automated_security_scan" {
  name             = "automated-security-scan"
  description      = "Job para scan de segurança automático"
  schedule         = "0 4 * * 0"  # Semanalmente no domingo às 4h
  time_zone        = "America/Sao_Paulo"
  
  http_target {
    http_method = "POST"
    uri         = "https://cloudbuild.googleapis.com/v1/projects/${var.project_id}/triggers/${google_cloudbuild_trigger.security_scan.trigger_id}:run"
    
    headers = {
      "Content-Type" = "application/json"
      "Authorization" = "Bearer ${data.google_client_config.default.access_token}"
    }
    
    body = base64encode(jsonencode({
      branchName = "main"
    }))
  }
  
  depends_on = [google_cloudbuild_trigger.security_scan]
}

# 10. Cloud Functions para webhook do GitHub
resource "google_cloudfunctions_function" "github_webhook" {
  name        = "github-webhook"
  description = "Função para processar webhooks do GitHub"
  runtime     = "python39"
  
  available_memory_mb   = 256
  source_archive_bucket = google_storage_bucket.backup_bucket.name
  source_archive_object = google_storage_bucket_object.webhook_function_zip.name
  trigger_http          = true
  entry_point           = "process_webhook"
  
  environment_variables = {
    PROJECT_ID = var.project_id
    REGION     = var.region
  }
  
  depends_on = [google_storage_bucket.backup_bucket]
}

# 11. Arquivo ZIP para a Cloud Function do webhook
resource "google_storage_bucket_object" "webhook_function_zip" {
  name   = "webhook-function.zip"
  bucket = google_storage_bucket.backup_bucket.name
  source = "${path.module}/functions/webhook-function.zip"
}

# 12. Cloud Functions para notificações de deploy
resource "google_cloudfunctions_function" "deploy_notification" {
  name        = "deploy-notification"
  description = "Função para enviar notificações de deploy"
  runtime     = "python39"
  
  available_memory_mb   = 256
  source_archive_bucket = google_storage_bucket.backup_bucket.name
  source_archive_object = google_storage_bucket_object.notification_function_zip.name
  trigger_http          = true
  entry_point           = "send_notification"
  
  environment_variables = {
    DISCORD_WEBHOOK_URL = var.discord_webhook_url
    EMAIL_SMTP_HOST     = var.email_smtp_host
    EMAIL_SMTP_PORT     = var.email_smtp_port
    EMAIL_USERNAME      = var.email_username
    EMAIL_PASSWORD      = var.email_password
  }
  
  depends_on = [google_storage_bucket.backup_bucket]
}

# 13. Arquivo ZIP para a Cloud Function de notificação
resource "google_storage_bucket_object" "notification_function_zip" {
  name   = "notification-function.zip"
  bucket = google_storage_bucket.backup_bucket.name
  source = "${path.module}/functions/notification-function.zip"
}

# 14. Cloud Functions para testes de estresse
resource "google_cloudfunctions_function" "stress_test_runner" {
  name        = "stress-test-runner"
  description = "Função para executar testes de estresse"
  runtime     = "python39"
  
  available_memory_mb   = 512
  source_archive_bucket = google_storage_bucket.backup_bucket.name
  source_archive_object = google_storage_bucket_object.stress_test_function_zip.name
  trigger_http          = true
  entry_point           = "run_stress_test"
  
  environment_variables = {
    CLUSTER_NAME = google_container_cluster.primary.name
    PROJECT_ID   = var.project_id
    REGION       = var.region
    APP_URL      = "https://${var.domain_name}"
  }
  
  depends_on = [google_storage_bucket.backup_bucket]
}

# 15. Arquivo ZIP para a Cloud Function de teste de estresse
resource "google_storage_bucket_object" "stress_test_function_zip" {
  name   = "stress-test-function.zip"
  bucket = google_storage_bucket.backup_bucket.name
  source = "${path.module}/functions/stress-test-function.zip"
}

# 16. Cloud Functions para análise de métricas
resource "google_cloudfunctions_function" "metrics_analyzer" {
  name        = "metrics-analyzer"
  description = "Função para análise de métricas e alertas"
  runtime     = "python39"
  
  available_memory_mb   = 512
  source_archive_bucket = google_storage_bucket.backup_bucket.name
  source_archive_object = google_storage_bucket_object.metrics_function_zip.name
  trigger_http          = true
  entry_point           = "analyze_metrics"
  
  environment_variables = {
    PROJECT_ID = var.project_id
    REGION     = var.region
    DATASET_ID = google_bigquery_dataset.cluster_metrics.dataset_id
  }
  
  depends_on = [google_storage_bucket.backup_bucket]
}

# 17. Arquivo ZIP para a Cloud Function de análise de métricas
resource "google_storage_bucket_object" "metrics_function_zip" {
  name   = "metrics-function.zip"
  bucket = google_storage_bucket.backup_bucket.name
  source = "${path.module}/functions/metrics-function.zip"
}

# 18. Cloud Functions para limpeza automática
resource "google_cloudfunctions_function" "cleanup_automation" {
  name        = "cleanup-automation"
  description = "Função para limpeza automática de recursos"
  runtime     = "python39"
  
  available_memory_mb   = 256
  source_archive_bucket = google_storage_bucket.backup_bucket.name
  source_archive_object = google_storage_bucket_object.cleanup_function_zip.name
  trigger_http          = true
  entry_point           = "cleanup_resources"
  
  environment_variables = {
    PROJECT_ID = var.project_id
    REGION     = var.region
    CLUSTER_NAME = google_container_cluster.primary.name
  }
  
  depends_on = [google_storage_bucket.backup_bucket]
}

# 19. Arquivo ZIP para a Cloud Function de limpeza
resource "google_storage_bucket_object" "cleanup_function_zip" {
  name   = "cleanup-function.zip"
  bucket = google_storage_bucket.backup_bucket.name
  source = "${path.module}/functions/cleanup-function.zip"
}

# 20. Cloud Functions para health check
resource "google_cloudfunctions_function" "health_check" {
  name        = "health-check"
  description = "Função para health check do ambiente"
  runtime     = "python39"
  
  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.backup_bucket.name
  source_archive_object = google_storage_bucket_object.health_check_function_zip.name
  trigger_http          = true
  entry_point           = "health_check"
  
  environment_variables = {
    PROJECT_ID = var.project_id
    REGION     = var.region
    CLUSTER_NAME = google_container_cluster.primary.name
  }
  
  depends_on = [google_storage_bucket.backup_bucket]
}

# 21. Arquivo ZIP para a Cloud Function de health check
resource "google_storage_bucket_object" "health_check_function_zip" {
  name   = "health-check-function.zip"
  bucket = google_storage_bucket.backup_bucket.name
  source = "${path.module}/functions/health-check-function.zip"
}

# 22. Cloud Scheduler para health check
resource "google_cloud_scheduler_job" "health_check_job" {
  name             = "health-check-job"
  description      = "Job para health check automático"
  schedule         = "*/15 * * * *"  # A cada 15 minutos
  time_zone        = "America/Sao_Paulo"
  
  http_target {
    http_method = "GET"
    uri         = google_cloudfunctions_function.health_check.https_trigger_url
    
    headers = {
      "Content-Type" = "application/json"
    }
  }
  
  depends_on = [google_cloudfunctions_function.health_check]
}

# 23. Cloud Scheduler para análise de métricas
resource "google_cloud_scheduler_job" "metrics_analysis_job" {
  name             = "metrics-analysis-job"
  description      = "Job para análise automática de métricas"
  schedule         = "*/30 * * * *"  # A cada 30 minutos
  time_zone        = "America/Sao_Paulo"
  
  http_target {
    http_method = "POST"
    uri         = google_cloudfunctions_function.metrics_analyzer.https_trigger_url
    
    headers = {
      "Content-Type" = "application/json"
    }
    
    body = base64encode(jsonencode({
      analysis_type = "automated"
      timestamp    = timestamp()
    }))
  }
  
  depends_on = [google_cloudfunctions_function.metrics_analyzer]
}

# 24. Cloud Scheduler para limpeza automática
resource "google_cloud_scheduler_job" "cleanup_job" {
  name             = "cleanup-job"
  description      = "Job para limpeza automática de recursos"
  schedule         = "0 3 * * *"  # Diariamente às 3h da manhã
  time_zone        = "America/Sao_Paulo"
  
  http_target {
    http_method = "POST"
    uri         = google_cloudfunctions_function.cleanup_automation.https_trigger_url
    
    headers = {
      "Content-Type" = "application/json"
    }
    
    body = base64encode(jsonencode({
      cleanup_type = "daily"
      timestamp   = timestamp()
    }))
  }
  
  depends_on = [google_cloudfunctions_function.cleanup_automation]
}
