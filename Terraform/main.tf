terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

# Configuração do provedor Google
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Configuração do provedor Kubernetes (após criar o cluster)
provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

# Configuração do provedor Helm
provider "helm" {
  kubernetes {
    host                   = "https://${google_container_cluster.primary.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  }
}

# Obter configuração do cliente Google
data "google_client_config" "default" {}

# 1. VPC e Subnets
resource "google_compute_network" "vpc" {
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project_id}-subnet"
  ip_cidr_range = var.subnet_cidr
  network       = google_compute_network.vpc.id
  region        = var.region
  
  # Habilitar logs de fluxo para monitoramento
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling       = 0.5
    metadata            = "INCLUDE_ALL_METADATA"
  }
}

# 2. Cluster GKE com alta disponibilidade
resource "google_container_cluster" "primary" {
  name     = "${var.project_id}-cluster"
  location = var.region
  
  # Configuração de alta disponibilidade
  node_locations = var.node_locations
  
  # Configuração de rede
  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.subnet.id
  
  # Configuração de segurança
  enable_shielded_nodes = true
  
  # Configuração de monitoramento
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
    # managed_prometheus removido - usando kube-prometheus-stack via Helm
  }
  
  # Configuração de logging
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }
  
  # Configuração de rede
  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.pods_cidr
    services_ipv4_cidr_block = var.services_cidr
  }
  
  # Configuração de master
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }
  
  # Configuração de workload identity
  
  # Configuração de release channel
  release_channel {
    channel = "REGULAR"
  }
  
  # Configuração de manutenção
  maintenance_policy {
    recurring_window {
      start_time = "2024-01-01T02:00:00Z"
      end_time   = "2024-01-01T06:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=SU"
    }
  }
  
  # Configuração de upgrade automático
  
  # Configuração de segurança
  enable_autopilot = false
  
  # Configuração de addons
  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    network_policy_config {
      disabled = false
    }
    # istio_config removido - configurado via Helm se necessário
  }
  
  # Configuração de network policy
  network_policy {
    enabled = true
    provider = "CALICO"
  }
  
  # Configuração de pod security policy removida - não suportada nesta versão
  
  # Configuração de binary authorization
  binary_authorization {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
  }
  
  # Configuração de confidential nodes
  confidential_nodes {
    enabled = true
  }
  
  # Configuração de shielded nodes removida - não suportada nesta versão
  
  # Configuração de cost management
  cost_management_config {
    enabled = true
  }
  
  # Configuração de fleet
  fleet {
    project = var.project_id
  }
  
  # Configuração de gateway
  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }
  
  # Configuração de mesh
  mesh_certificates {
    enable_certificates = true
  }
  
  # Configuração de notification
  notification_config {
    pubsub {
      enabled = true
      topic   = google_pubsub_topic.cluster_notifications.id
    }
  }
  
  # Configuração de resource usage export
  resource_usage_export_config {
    enable_network_egress_metering = true
    enable_resource_consumption_metering = true
    bigquery_destination {
      dataset_id = google_bigquery_dataset.cluster_metrics.dataset_id
    }
  }
  
  # Configuração de service mesh
  service_mesh_config {
    enable_managed_service_mesh = true
  }
  
  # Configuração de tpu config
  tpu_config {
    enabled = false
  }
  
  # Configuração de vertical pod autoscaling
  vertical_pod_autoscaling {
    enabled = true
  }
  
  # Configuração de windows node config
  windows_node_config {
    os_version = "WINDOWS_LTSC"
  }
  
  # Configuração de workload identity config
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  
  # Configuração de default max pods per node
  default_max_pods_per_node = 110
  
  # Configuração de enable intranode visibility
  enable_intranode_visibility = true
  
  # Configuração de enable kubernetes alpha
  enable_kubernetes_alpha = false
  
  # Configuração de enable legacy abac
  enable_legacy_abac = false
  
  # Configuração de enable tpu
  enable_tpu = false
  
  # Configuração de initial node count
  initial_node_count = 1
  
  # Configuração de location
  location = var.region
  
  # Configuração de logging service
  logging_service = "logging.googleapis.com/kubernetes"
  
  # Configuração de monitoring service
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  
  # Configuração de name
  name = "${var.project_id}-cluster"
  
  # Configuração de network
  network = google_compute_network.vpc.id
  
  # Configuração de networking mode
  networking_mode = "VPC_NATIVE"
  
  # Configuração de node version
  node_version = "1.27"
  
  # Configuração de project
  project = var.project_id
  
  # Configuração de region
  region = var.region
  
  # Configuração de remove default node pool
  remove_default_node_pool = true
  
  # Configuração de resource labels
  resource_labels = {
    environment = "production"
    project     = var.project_id
    managed_by  = "terraform"
  }
  
  # Configuração de subnetwork
  subnetwork = google_compute_subnetwork.subnet.id
  
  # Configuração de zone
  zone = var.zone
}

# 3. Node Pool para alta disponibilidade (mínimo 2 workers)
resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.project_id}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count
  
  # Configuração de upgrade automático
  management {
    auto_repair  = true
    auto_upgrade = true
  }
  
  # Configuração de auto-scaling
  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }
  
  # Configuração dos nós
  node_config {
    # Configuração de imagem
    image_type = "COS_CONTAINERD"
    
    # Configuração de machine type
    machine_type = var.machine_type
    
    # Configuração de disk
    disk_size_gb = var.disk_size_gb
    disk_type    = "pd-standard"
    
    # Configuração de labels
    labels = {
      environment = "production"
      project     = var.project_id
      managed_by  = "terraform"
    }
    
    # Configuração de taints
    taint {
      key    = "dedicated"
      value  = "production"
      effect = "NO_SCHEDULE"
    }
    
    # Configuração de tags
    tags = ["gke-node", "${var.project_id}-node"]
    
    # Configuração de oauth scopes
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/compute"
    ]
    
    # Configuração de service account
    service_account = google_service_account.gke_node.email
    
    # Configuração de workload identity
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    
    # Configuração de shielded instance
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
    
    # Configuração de kubelet config
    kubelet_config {
      cpu_manager_policy = "static"
      cpu_cfs_quota     = true
      cpu_cfs_quota_period = "100us"
    }
    
    # Configuração de linux node config
    linux_node_config {
      sysctls = {
        "net.core.somaxconn" = "65535"
        "net.ipv4.tcp_max_syn_backlog" = "65535"
      }
    }
    
    # Configuração de gvnic
    gvnic {
      enabled = true
    }
    
    # Configuração de spot instances (opcional para economia)
    spot = false
  }
  
  # Configuração de upgrade strategy
  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }
}

# 4. Service Account para os nós GKE
resource "google_service_account" "gke_node" {
  account_id   = "gke-node-sa"
  display_name = "Service Account para nós GKE"
}

# 5. IAM para os nós GKE
resource "google_project_iam_member" "gke_node_worker" {
  project = var.project_id
  role    = "roles/container.nodeServiceAccount"
  member  = "serviceAccount:${google_service_account.gke_node.email}"
}

# 6. Firewall para o cluster
resource "google_compute_firewall" "gke_master" {
  name    = "gke-master-${var.project_id}"
  network = google_compute_network.vpc.name
  
  allow {
    protocol = "tcp"
    ports    = ["443", "6443"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["gke-master"]
}

resource "google_compute_firewall" "gke_nodes" {
  name    = "gke-nodes-${var.project_id}"
  network = google_compute_network.vpc.name
  
  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }
  
  allow {
    protocol = "udp"
    ports    = ["30000-32767"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["gke-node"]
}

# 7. Cloud NAT para nós privados
resource "google_compute_router" "router" {
  name    = "${var.project_id}-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.project_id}-nat"
  router                            = google_compute_router.router.name
  region                            = var.region
  nat_ip_allocate_option            = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# 8. Pub/Sub para notificações do cluster
resource "google_pubsub_topic" "cluster_notifications" {
  name = "cluster-notifications"
}

# 9. BigQuery para métricas do cluster
resource "google_bigquery_dataset" "cluster_metrics" {
  dataset_id  = "cluster_metrics"
  description = "Dataset para métricas do cluster GKE"
  location    = var.region
  
  labels = {
    environment = "production"
    project     = var.project_id
    managed_by  = "terraform"
  }
}

# 10. Cloud Monitoring para alertas
resource "google_monitoring_alert_policy" "cluster_health" {
  display_name = "Cluster Health Alert"
  combiner     = "OR"
  
  conditions {
    display_name = "Cluster unhealthy"
    
    condition_threshold {
      filter     = "metric.type=\"kubernetes.io/container/restart_count\""
      duration   = "300s"
      comparison = "COMPARISON_GREATER_THAN"
      threshold_value = 5
      
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }
  
  notification_channels = [google_monitoring_notification_channel.email.name]
}

# 11. Canal de notificação por email
resource "google_monitoring_notification_channel" "email" {
  display_name = "Email Notification Channel"
  type         = "email"
  
  labels = {
    email_address = var.alert_email
  }
}

# 12. Cloud Logging para logs do cluster
resource "google_logging_project_sink" "cluster_logs" {
  name        = "cluster-logs-sink"
  destination = "bigquery.googleapis.com/projects/${var.project_id}/datasets/${google_bigquery_dataset.cluster_metrics.dataset_id}"
  
  filter = "resource.type=\"k8s_cluster\""
  
  unique_writer_identity = true
}

# 13. IAM para o sink de logs
resource "google_project_iam_member" "log_writer" {
  project = google_logging_project_sink.cluster_logs.project
  role    = "roles/bigquery.dataEditor"
  member  = google_logging_project_sink.cluster_logs.writer_identity
}

# 14. Cloud Armor para segurança adicional
resource "google_compute_security_policy" "security_policy" {
  name = "security-policy"
  
  rule {
    action   = "deny(403)"
    priority = "1000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["0.0.0.0/0"]
      }
    }
    description = "Deny access by default"
  }
  
  rule {
    action   = "allow"
    priority = "2000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = var.allowed_ip_ranges
      }
    }
    description = "Allow access from specified IP ranges"
  }
}

# 15. Cloud KMS para criptografia
resource "google_kms_key_ring" "keyring" {
  name     = "gke-keyring"
  location = var.region
}

resource "google_kms_crypto_key" "key" {
  name     = "gke-key"
  key_ring = google_kms_key_ring.keyring.id
  
  lifecycle {
    prevent_destroy = true
  }
}

# 16. IAM para Cloud KMS
resource "google_kms_crypto_key_iam_member" "crypto_key" {
  crypto_key_id = google_kms_crypto_key.key.id
  role           = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member         = "serviceAccount:${google_service_account.gke_node.email}"
}

# 17. Cloud Storage para backups
resource "google_storage_bucket" "backup_bucket" {
  name          = "${var.project_id}-backup-bucket"
  location      = var.region
  force_destroy = false
  
  versioning {
    enabled = true
  }
  
  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
  
  labels = {
    environment = "production"
    project     = var.project_id
    managed_by  = "terraform"
  }
}

# 18. IAM para o bucket de backup
resource "google_storage_bucket_iam_member" "backup_bucket_iam" {
  bucket = google_storage_bucket.backup_bucket.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.gke_node.email}"
}

# 19. Cloud Functions para automação
resource "google_cloudfunctions_function" "backup_function" {
  name        = "backup-function"
  description = "Função para backup automático do cluster"
  runtime     = "python39"
  
  available_memory_mb   = 256
  source_archive_bucket = google_storage_bucket.backup_bucket.name
  source_archive_object = google_storage_bucket_object.backup_function_zip.name
  trigger_http          = true
  entry_point           = "backup_cluster"
}

# 20. Arquivo ZIP para a Cloud Function
resource "google_storage_bucket_object" "backup_function_zip" {
  name   = "backup-function.zip"
  bucket = google_storage_bucket.backup_bucket.name
  source = "${path.module}/functions/backup-function.zip"
}

# 21. Cloud Scheduler para execução automática
resource "google_cloud_scheduler_job" "backup_job" {
  name             = "backup-job"
  description      = "Job para backup automático do cluster"
  schedule         = "0 2 * * *"  # Diariamente às 2h da manhã
  time_zone        = "America/Sao_Paulo"
  
  http_target {
    http_method = "POST"
    uri         = google_cloudfunctions_function.backup_function.https_trigger_url
    
    headers = {
      "Content-Type" = "application/json"
    }
    
    body = base64encode(jsonencode({
      cluster_name = google_container_cluster.primary.name
      project_id   = var.project_id
      region       = var.region
    }))
  }
}

# 22. Cloud Build para CI/CD
resource "google_cloudbuild_trigger" "infrastructure_trigger" {
  name        = "infrastructure-trigger"
  description = "Trigger para deploy da infraestrutura"
  
  github {
    owner  = var.github_owner
    name   = var.github_repo
    push {
      branch = "main"
    }
  }
  
  filename = "cloudbuild.yaml"
  
  substitutions = {
    _CLUSTER_NAME = google_container_cluster.primary.name
    _PROJECT_ID   = var.project_id
    _REGION       = var.region
  }
}

# 23. Cloud Run para aplicação de exemplo
resource "google_cloud_run_service" "whoami_app" {
  name     = "whoami-app"
  location = var.region
  
  template {
    spec {
      containers {
        image = "jwilder/whoami:latest"
        
        ports {
          container_port = 8000
        }
        
        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
        
        env {
          name  = "NODE_ENV"
          value = "production"
        }
      }
      
      service_account_name = google_service_account.gke_node.email
    }
  }
  
  traffic {
    percent         = 100
    latest_revision = true
  }
}

# 24. IAM para Cloud Run
resource "google_cloud_run_service_iam_member" "public_access" {
  location = google_cloud_run_service.whoami_app.location
  service  = google_cloud_run_service.whoami_app.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# 25. Load Balancer para alta disponibilidade
resource "google_compute_global_forwarding_rule" "default" {
  name       = "global-forwarding-rule"
  target    = google_compute_target_https_proxy.default.id
  port_range = "443"
}

resource "google_compute_target_https_proxy" "default" {
  name             = "target-https-proxy"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
}

resource "google_compute_url_map" "default" {
  name            = "url-map"
  default_service = google_compute_backend_service.default.id
}

resource "google_compute_backend_service" "default" {
  name        = "backend-service"
  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 10
  
  backend {
    group = google_compute_instance_group_manager.default.instance_group
  }
  
  health_checks = [google_compute_health_check.default.id]
}

resource "google_compute_instance_group_manager" "default" {
  name = "instance-group-manager"
  
  base_instance_name = "whoami"
  zone               = var.zone
  
  version {
    instance_template = google_compute_instance_template.default.id
  }
  
  target_size = 2
  
  named_port {
    name = "http"
    port = 8000
  }
}

resource "google_compute_instance_template" "default" {
  name_prefix  = "whoami-template-"
  machine_type = "e2-micro"
  
  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }
  
  network_interface {
    network = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet.id
    
    access_config {
      // Ephemeral public IP
    }
  }
  
  metadata_startup_script = <<-EOF
              #!/bin/bash
              docker run -d -p 8000:8000 jwilder/whoami:latest
              EOF
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_health_check" "default" {
  name = "health-check"
  
  http_health_check {
    port = 8000
  }
}

resource "google_compute_managed_ssl_certificate" "default" {
  name = "managed-ssl-certificate"
  
  managed {
    domains = [var.domain_name]
  }
}

# 26. DNS para o domínio
resource "google_dns_managed_zone" "default" {
  name        = "default-zone"
  dns_name    = "${var.domain_name}."
  description = "DNS zone for the project"
}

resource "google_dns_record_set" "default" {
  name         = var.domain_name
  managed_zone = google_dns_managed_zone.default.name
  type         = "A"
  ttl          = 300
  
  rrdatas = [google_compute_global_forwarding_rule.default.ip_address]
}

# 27. Cloud Monitoring para métricas customizadas
resource "google_monitoring_custom_service" "whoami_service" {
  service_id = "whoami-service"
  display_name = "WhoAmI Service"
  
  telemetry {
    resource_name = google_cloud_run_service.whoami_app.name
  }
}

# 28. Cloud Logging para logs da aplicação
resource "google_logging_project_sink" "app_logs" {
  name        = "app-logs-sink"
  destination = "bigquery.googleapis.com/projects/${var.project_id}/datasets/${google_bigquery_dataset.cluster_metrics.dataset_id}"
  
  filter = "resource.type=\"cloud_run_revision\""
  
  unique_writer_identity = true
}

# 29. IAM para o sink de logs da aplicação
resource "google_project_iam_member" "app_log_writer" {
  project = google_logging_project_sink.app_logs.project
  role    = "roles/bigquery.dataEditor"
  member  = google_logging_project_sink.app_logs.writer_identity
}

# 30. Cloud Monitoring para alertas da aplicação
resource "google_monitoring_alert_policy" "app_health" {
  display_name = "Application Health Alert"
  combiner     = "OR"
  
  conditions {
    display_name = "Application unhealthy"
    
    condition_threshold {
      filter     = "metric.type=\"run.googleapis.com/request_count\""
      duration   = "300s"
      comparison = "COMPARISON_LESS_THAN"
      threshold_value = 1
      
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }
  
  notification_channels = [google_monitoring_notification_channel.email.name]
}

# 31. Cloud Monitoring para alertas de performance
resource "google_monitoring_alert_policy" "performance_alert" {
  display_name = "Performance Alert"
  combiner     = "OR"
  
  conditions {
    display_name = "High response time"
    
    condition_threshold {
      filter     = "metric.type=\"run.googleapis.com/request_latencies\""
      duration   = "300s"
      comparison = "COMPARISON_GREATER_THAN"
      threshold_value = 1000  # 1 segundo
      
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }
  
  notification_channels = [google_monitoring_notification_channel.email.name]
}

# 32. Cloud Monitoring para alertas de erro
resource "google_monitoring_alert_policy" "error_alert" {
  display_name = "Error Rate Alert"
  combiner     = "OR"
  
  conditions {
    display_name = "High error rate"
    
    condition_threshold {
      filter     = "metric.type=\"run.googleapis.com/request_count\" AND metric.labels.response_code_class=\"5xx\""
      duration   = "300s"
      comparison = "COMPARISON_GREATER_THAN"
      threshold_value = 10
      
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }
  
  notification_channels = [google_monitoring_notification_channel.email.name]
}

# 33. Cloud Monitoring para alertas de disponibilidade
resource "google_monitoring_alert_policy" "availability_alert" {
  display_name = "Availability Alert"
  combiner     = "OR"
  
  conditions {
    display_name = "Low availability"
    
    condition_threshold {
      filter     = "metric.type=\"run.googleapis.com/request_count\""
      duration   = "300s"
      comparison = "COMPARISON_LESS_THAN"
      threshold_value = 1
      
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }
  
  notification_channels = [google_monitoring_notification_channel.email.name]
}

# 34. Cloud Monitoring para alertas de recursos
resource "google_monitoring_alert_policy" "resource_alert" {
  display_name = "Resource Usage Alert"
  combiner     = "OR"
  
  conditions {
    display_name = "High CPU usage"
    
    condition_threshold {
      filter     = "metric.type=\"run.googleapis.com/container/cpu/utilizations\""
      duration   = "300s"
      comparison = "COMPARISON_GREATER_THAN"
      threshold_value = 80
      
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }
  
  conditions {
    display_name = "High memory usage"
    
    condition_threshold {
      filter     = "metric.type=\"run.googleapis.com/container/memory/utilizations\""
      duration   = "300s"
      comparison = "COMPARISON_GREATER_THAN"
      threshold_value = 80
      
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }
  
  notification_channels = [google_monitoring_notification_channel.email.name]
}

# 35. Cloud Monitoring para alertas de custo
resource "google_monitoring_alert_policy" "cost_alert" {
  display_name = "Cost Alert"
  combiner     = "OR"
  
  conditions {
    display_name = "High cost"
    
    condition_threshold {
      filter     = "metric.type=\"billing.googleapis.com/billing/budget/budget_amount\""
      duration   = "86400s"  # 24 horas
      comparison = "COMPARISON_GREATER_THAN"
      threshold_value = 100  # $100 USD
      
      aggregations {
        alignment_period   = "86400s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
  
  notification_channels = [google_monitoring_notification_channel.email.name]
}

# 36. Cloud Monitoring para alertas de segurança
resource "google_monitoring_alert_policy" "security_alert" {
  display_name = "Security Alert"
  combiner     = "OR"
  
  conditions {
    display_name = "Failed authentication attempts"
    
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/log_entry_count\" AND resource.labels.resource_type=\"k8s_cluster\""
      duration   = "300s"
      comparison = "COMPARISON_GREATER_THAN"
      threshold_value = 10
      
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }
  
  notification_channels = [google_monitoring_notification_channel.email.name]
}

# 37. Cloud Monitoring para alertas de rede
resource "google_monitoring_alert_policy" "network_alert" {
  display_name = "Network Alert"
  combiner     = "OR"
  
  conditions {
    display_name = "High network latency"
    
    condition_threshold {
      filter     = "metric.type=\"run.googleapis.com/request_latencies\""
      duration   = "300s"
      comparison = "COMPARISON_GREATER_THAN"
      threshold_value = 2000  # 2 segundos
      
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }
  
  notification_channels = [google_monitoring_notification_channel.email.name]
}

# 38. Cloud Monitoring para alertas de backup
resource "google_monitoring_alert_policy" "backup_alert" {
  display_name = "Backup Alert"
  combiner     = "OR"
  
  conditions {
    display_name = "Backup failed"
    
    condition_threshold {
      filter     = "metric.type=\"cloudfunctions.googleapis.com/function/execution_count\" AND resource.labels.function_name=\"${google_cloudfunctions_function.backup_function.name}\""
      duration   = "86400s"  # 24 horas
      comparison = "COMPARISON_LESS_THAN"
      threshold_value = 1
      
      aggregations {
        alignment_period   = "86400s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
  
  notification_channels = [google_monitoring_notification_channel.email.name]
}

# 39. Cloud Monitoring para alertas de certificado SSL
resource "google_monitoring_alert_policy" "ssl_alert" {
  display_name = "SSL Certificate Alert"
  combiner     = "OR"
  
  conditions {
    display_name = "SSL certificate expiring soon"
    
    condition_threshold {
      filter     = "metric.type=\"ssl.googleapis.com/ssl/certificate/expiry_time\""
      duration   = "604800s"  # 7 dias
      comparison = "COMPARISON_LESS_THAN"
      threshold_value = timeadd(timestamp(), "7d")
      
      aggregations {
        alignment_period   = "604800s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }
  
  notification_channels = [google_monitoring_notification_channel.email.name]
}

# 40. Cloud Monitoring para alertas de domínio
resource "google_monitoring_alert_policy" "domain_alert" {
  display_name = "Domain Alert"
  combiner     = "OR"
  
  conditions {
    display_name = "Domain resolution failed"
    
    condition_threshold {
      filter     = "metric.type=\"dns.googleapis.com/query/volume\""
      duration   = "300s"
      comparison = "COMPARISON_LESS_THAN"
      threshold_value = 1
      
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
  
  notification_channels = [google_monitoring_notification_channel.email.name]
}
