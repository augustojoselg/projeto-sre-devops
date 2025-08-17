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

# Módulo para criar conta de serviço DevOps
module "service_account" {
  source = "./service_account"

  project_id = var.project_id
  region     = var.region
}

# 1. VPC e Subnets (REUTILIZÁVEL - só cria se não existir)
data "google_compute_network" "vpc" {
  name = "${var.project_id}-vpc"
}

# Fallback para criar VPC se não existir
resource "google_compute_network" "vpc" {
  count                   = data.google_compute_network.vpc.name == "${var.project_id}-vpc" ? 0 : 1
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"

  depends_on = [google_project_service.compute]

  # Tornar reutilizável
  lifecycle {
    create_before_destroy = true
  }
}

# Usar VPC existente ou criada
locals {
  vpc_id = data.google_compute_network.vpc.name == "${var.project_id}-vpc" ? data.google_compute_network.vpc.id : google_compute_network.vpc[0].id
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project_id}-subnet"
  ip_cidr_range = var.subnet_cidr
  network       = local.vpc_id
  region        = var.region

  # Habilitar logs de fluxo para monitoramento
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

  depends_on = [google_project_service.compute]
}

# Cluster GKE com configurações otimizadas
resource "google_container_cluster" "primary" {
  name     = "${var.project_id}-cluster"
  location = var.region
  project  = var.project_id

  # DESABILITADO AUTOPILOT - Cluster Standard para controle total
  # enable_autopilot = false  # Removido para usar cluster Standard

  # Configuração de rede
  network    = local.vpc_id
  subnetwork = google_compute_subnetwork.subnet.name

  # Configuração de IP para pods e serviços
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.pods_cidr
    services_ipv4_cidr_block = var.services_cidr
  }

  # Configuração de rede privada
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  # Redes autorizadas para acesso ao master
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "All"
    }
  }

  # Configuração de addons
  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    network_policy_config {
      disabled = true # Desabilitado para compatibilidade
    }
  }

  # Canal de release estável
  release_channel {
    channel = "STABLE"
  }

  # Política de manutenção (comentada - requer configuração adequada)
  # maintenance_policy {
  #   recurring_window {
  #     start_time = "2025-01-01T02:00:00Z"
  #     end_time   = "2025-01-01T06:00:00Z"
  #     recurrence = "FREQ=WEEKLY;BYDAY=SU"
  #   }
  # }

  # Configuração de node pool com limites de disco
  node_pool {
    name       = "default-pool"
    node_count = var.node_count

    # Configuração de autoscaling com limites
    autoscaling {
      min_node_count = var.min_node_count
      max_node_count = var.max_node_count
    }

    # Configuração dos nós
    node_config {
      machine_type = var.machine_type
      disk_size_gb = var.disk_size_gb
      disk_type    = "pd-standard"

      # Labels para organização
      labels = {
        environment = "production"
        project     = var.project_id
      }

      # Service account para os nós
      service_account = data.google_service_account.gke_node.email
      oauth_scopes = [
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring",
        "https://www.googleapis.com/auth/devstorage.read_only"
      ]

      # Configuração de metadados
      metadata = {
        disable-legacy-endpoints = "true"
      }

      # Configuração de workload identity
      workload_metadata_config {
        mode = "GKE_METADATA"
      }

      # Configuração de shielded instance
      shielded_instance_config {
        enable_secure_boot          = true
        enable_integrity_monitoring = true
      }
    }

    # Configuração de upgrade
    management {
      auto_repair  = true
      auto_upgrade = true
    }

    # Configuração de upgrade com rolling
    upgrade_settings {
      max_surge       = 1
      max_unavailable = 0
    }
  }

  # Configuração de logging e monitoring
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  # Configuração de resource usage export (comentada - requer BigQuery)
  # resource_usage_export_config {
  #   enable_network_egress_metering = true
  #   enable_resource_consumption_metering = true
  #   bigquery_destination {
  #     dataset_id = "gke_usage_metering"
  #   }
  # }

  # Configuração de workload identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Dependências
  depends_on = [
    google_compute_network.vpc,
    google_compute_subnetwork.subnet,
    google_project_service.container,
    data.google_service_account.gke_node
  ]

  # Lifecycle para evitar destruição acidental
  lifecycle {
    prevent_destroy = false # Permitir destruição para mudança de região
    ignore_changes = [
      node_pool[0].node_config[0].resource_labels,
      node_pool[0].node_config[0].kubelet_config
    ]
  }
}



# 4. Service Account para os nós GKE (já existe)
data "google_service_account" "gke_node" {
  account_id = "gke-node-sa"
  project    = var.project_id
}

# 5. IAM para os nós GKE
resource "google_project_iam_member" "gke_node_worker" {
  project = var.project_id
  role    = "roles/container.nodeServiceAccount"
  member  = "serviceAccount:${data.google_service_account.gke_node.email}"
}

# 6. Firewall para o cluster
resource "google_compute_firewall" "gke_master" {
  name    = "gke-master-${var.project_id}"
  network = local.vpc_id

  allow {
    protocol = "tcp"
    ports    = ["443", "6443"]
  }

  source_ranges = var.allowed_ip_ranges
  target_tags   = ["gke-master"]
}

resource "google_compute_firewall" "gke_nodes" {
  name    = "gke-nodes-${var.project_id}"
  network = local.vpc_id

  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }

  allow {
    protocol = "udp"
    ports    = ["30000-32767"]
  }

  source_ranges = var.allowed_ip_ranges
  target_tags   = ["gke-node"]
}

# 7. Cloud NAT para nós privados
resource "google_compute_router" "router" {
  name    = "${var.project_id}-router"
  region  = var.region
  network = local.vpc_id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.project_id}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}





# 10. Cloud Monitoring para alertas (SUBSTITUÍDO POR PROMETHEUS + GRAFANA)
# resource "google_monitoring_alert_policy" "cluster_health" {
#   display_name = "Cluster Health Alert"
#   combiner     = "OR"
#   
#   conditions {
#     display_name = "Cluster unhealthy"
#     
#     condition_threshold {
#       filter     = "metric.type=\"kubernetes.io/container/restart_count\" AND resource.type=\"k8s_container\""
#       duration   = "300s"
#       comparison = "COMPARISON_GT"
#       threshold_value = 5
#       
#       aggregations {
#         alignment_period   = "300s"
#         per_series_aligner = "ALIGN_RATE"
#       }
#     }
#   }
#   
#   notification_channels = [google_monitoring_notification_channel.email.name]
# }

# 11. Canal de notificação por email (SUBSTITUÍDO POR PROMETHEUS ALERTMANAGER)
# resource "google_monitoring_notification_channel" "email" {
#   display_name = "Email Notification Channel"
#   type         = "email"
#   
#   labels = {
#     email_address = var.alert_email
#   }
# }



# 14. Cloud Armor para segurança adicional (REUTILIZÁVEL)
resource "google_compute_security_policy" "security_policy" {
  name = "security-policy"

  # REGRA PADRÃO OBRIGATÓRIA (prioridade 2147483647)
  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default rule, higher priority overrides"
  }

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

  rule {
    action   = "deny(403)"
    priority = "3000"
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('sqli-stable')"
      }
    }
    description = "Block SQL injection attacks"
  }

  rule {
    action   = "deny(403)"
    priority = "4000"
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('xss-stable')"
      }
    }
    description = "Block XSS attacks"
  }
  
  # Tornar reutilizável
  lifecycle {
    create_before_destroy = true
  }
}

# Usar Security Policy existente ou criada
locals {
  security_policy_id = data.google_compute_security_policy.security_policy.name == "security-policy" ? data.google_compute_security_policy.security_policy.id : google_compute_security_policy.security_policy[0].id
}

# 15. Cloud KMS para criptografia (REUTILIZÁVEL)
resource "google_kms_key_ring" "keyring" {
  name     = "gke-keyring"
  location = var.region
  
  # Tornar reutilizável
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_kms_crypto_key" "key" {
  name      = "gke-key"
  key_ring  = google_kms_key_ring.keyring.id

  lifecycle {
    prevent_destroy = true
    create_before_destroy = true
  }
}

# Usar Crypto Key existente ou criado
locals {
  crypto_key_id = google_kms_crypto_key.key.id
}

# 16. IAM para Cloud KMS
resource "google_kms_crypto_key_iam_member" "crypto_key" {
  crypto_key_id = google_kms_crypto_key.key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${data.google_service_account.gke_node.email}"
  
  # Tornar reutilizável
  lifecycle {
    create_before_destroy = true
  }
}



# 22. Cloud Build para CI/CD (TEMPORARIAMENTE COMENTADO PARA RESOLVER PROBLEMAS)
# resource "google_cloudbuild_trigger" "infrastructure_trigger" {
#   name        = "infrastructure-trigger"
#   description = "Trigger para deploy da infraestrutura"
#   location    = "global"
#   
#   github {
#     owner  = var.github_owner
#     name   = var.github_repo
#     push {
#       branch = "main"
#     }
#   }
#   
#   filename = "cloudbuild.yaml"
#   
#   substitutions = {
#     _CLUSTER_NAME = google_container_cluster.primary.name
#     _PROJECT_ID   = var.project_id
#     _REGION       = var.region
#   }
#   
#   depends_on = [google_project_service.cloudbuild]
#   
#   # Configurações adicionais para resolver problemas de validação
#   approval_config {
#     approval_required = false
#   }
# }

# 23. Cloud Run para aplicação de exemplo (REUTILIZÁVEL - só cria se não existir)
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

      service_account_name = data.google_service_account.gke_node.email
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  # Tornar reutilizável - só recria se houver mudanças
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      # Ignora mudanças que não afetam a funcionalidade
      template[0].metadata[0].annotations,
      template[0].metadata[0].labels
    ]
  }

  # Adicionar tags para identificação
  metadata {
    labels = {
      app         = "whoami"
      environment = "production"
      managed_by  = "terraform"
      version     = "v1-0-0"
    }
  }
}

# 24. IAM para Cloud Run (REUTILIZÁVEL)
resource "google_cloud_run_service_iam_member" "public_access" {
  location = google_cloud_run_service.whoami_app.location
  service  = google_cloud_run_service.whoami_app.name
  role     = "roles/run.invoker"
  member   = "allUsers"

  # Tornar reutilizável
  lifecycle {
    create_before_destroy = true
  }
}

# 25. Load Balancer para alta disponibilidade (REUTILIZÁVEL - só cria se não existir)
resource "google_compute_global_forwarding_rule" "default" {
  name       = "global-forwarding-rule"
  target     = google_compute_target_https_proxy.default.id
  port_range = "443"

  # Tornar reutilizável
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_target_https_proxy" "default" {
  name             = "target-https-proxy"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]

  # Tornar reutilizável
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_url_map" "default" {
  name            = "url-map"
  default_service = google_compute_backend_service.default.id

  # Tornar reutilizável
  lifecycle {
    create_before_destroy = true
  }
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

  # Tornar reutilizável
  lifecycle {
    create_before_destroy = true
  }
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

  # Tornar reutilizável
  lifecycle {
    create_before_destroy = true
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
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet.id

    access_config {
      // Ephemeral public IP
    }
  }

  metadata_startup_script = <<-EOF
              #!/bin/bash
              docker run -d -p 8000:8000 jwilder/whoami:latest
              EOF

  # Tornar reutilizável
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_health_check" "default" {
  name = "health-check"

  http_health_check {
    port = 8000
  }

  # Tornar reutilizável
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_managed_ssl_certificate" "default" {
  name = "managed-ssl-certificate"

  managed {
    domains = [var.domain_name]
  }

  # Tornar reutilizável
  lifecycle {
    create_before_destroy = true
  }
}

# 26. DNS para o domínio
resource "google_dns_managed_zone" "default" {
  name        = "default-zone"
  dns_name    = "${var.domain_name}."
  description = "DNS zone for the project"
}

resource "google_dns_record_set" "default" {
  name         = "${var.domain_name}."
  managed_zone = google_dns_managed_zone.default.name
  type         = "A"
  ttl          = 300

  rrdatas = [google_compute_global_forwarding_rule.default.ip_address]
}

# 27. Cloud Monitoring para métricas customizadas (SUBSTITUÍDO POR PROMETHEUS + GRAFANA)
# resource "google_monitoring_custom_service" "whoami_service" {
#   service_id = "whoami-service"
#   display_name = "WhoAmI Service"
#   
#   telemetry {
#     resource_name = google_cloud_run_service.whoami_app.name
#   }
# }



# 30. Cloud Monitoring para alertas da aplicação (SUBSTITUÍDO POR PROMETHEUS + GRAFANA)
# resource "google_monitoring_alert_policy" "app_health" {
#   display_name = "Application Health Alert"
#   combiner     = "OR"
#   
#   conditions {
#     display_name = "Application unhealthy"
#     
#     condition_threshold {
#       filter     = "metric.type=\"run.googleapis.com/request_count\" AND resource.type=\"cloud_run_revision\""
#       duration   = "300s"
#       comparison = "COMPARISON_LT"
#       threshold_value = 1
#       
#       aggregations {
#         alignment_period   = "300s"
#         per_series_aligner = "ALIGN_RATE"
#       }
#     }
#   }
#   
#   notification_channels = [google_monitoring_notification_channel.email.name]
# }

# 31. Cloud Monitoring para alertas de performance (SUBSTITUÍDO POR PROMETHEUS + GRAFANA)
# resource "google_monitoring_alert_policy" "performance_alert" {
#   display_name = "Performance Alert"
#   combiner     = "OR"
#   
#   conditions {
#     display_name = "High response time"
#     
#     condition_threshold {
#       filter     = "metric.type=\"run.googleapis.com/request_latencies\" AND resource.type=\"cloud_run_revision\""
#       duration   = "300s"
#       comparison = "COMPARISON_GT"
#       threshold_value = 1000  # 1 segundo
#       
#       aggregations {
#         alignment_period   = "300s"
#         per_series_aligner = "ALIGN_PERCENTILE_95"
#       }
#     }
#   }
#   
#   notification_channels = [google_monitoring_notification_channel.email.name]
# }

# 32-34. Cloud Monitoring para alertas (SUBSTITUÍDO POR PROMETHEUS + GRAFANA)
# Todos os alertas foram comentados para usar Prometheus + Grafana

# 35-37. Cloud Monitoring para alertas (SUBSTITUÍDO POR PROMETHEUS + GRAFANA)
# Todos os alertas foram comentados para usar Prometheus + Grafana



# 39-40. Cloud Monitoring para alertas (SUBSTITUÍDO POR PROMETHEUS + GRAFANA)
# Todos os alertas foram comentados para usar Prometheus + Grafana
