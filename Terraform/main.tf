# Configuração do provedor Google
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Configuração do provedor Kubernetes (após criar o cluster)
provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.existing_cluster.name == "${var.project_id}-cluster" ? data.google_container_cluster.existing_cluster.endpoint : google_container_cluster.primary[0].endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.existing_cluster.name == "${var.project_id}-cluster" ? data.google_container_cluster.existing_cluster.master_auth[0].cluster_ca_certificate : google_container_cluster.primary[0].master_auth[0].cluster_ca_certificate)
}

# Configuração do provedor Helm
provider "helm" {
  kubernetes {
    host                   = "https://${data.google_container_cluster.existing_cluster.name == "${var.project_id}-cluster" ? data.google_container_cluster.existing_cluster.endpoint : google_container_cluster.primary[0].endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.existing_cluster.name == "${var.project_id}-cluster" ? data.google_container_cluster.existing_cluster.master_auth[0].cluster_ca_certificate : google_container_cluster.primary[0].master_auth[0].cluster_ca_certificate)
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
# Verificar se a VPC já existe
data "google_compute_network" "existing_vpc" {
  name = "${var.project_id}-vpc"
}

# Fallback para criar VPC se não existir
resource "google_compute_network" "vpc" {
  count                   = data.google_compute_network.existing_vpc.name == "${var.project_id}-vpc" ? 0 : 1
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"

  depends_on = [google_project_service.compute]

  # Tornar reutilizável
  lifecycle {
    create_before_destroy = true
  }
}

# Verificar se a subnet já existe
data "google_compute_subnetwork" "existing_subnet" {
  name   = "${var.project_id}-subnet"
  region = var.region
}

# Fallback para criar subnet se não existir
resource "google_compute_subnetwork" "subnet" {
  count         = data.google_compute_subnetwork.existing_subnet.name == "${var.project_id}-subnet" ? 0 : 1
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

# Usar VPC existente ou criada
locals {
  vpc_id    = data.google_compute_network.existing_vpc.name == "${var.project_id}-vpc" ? data.google_compute_network.existing_vpc.id : google_compute_network.vpc[0].id
  subnet_id = data.google_compute_subnetwork.existing_subnet.name == "${var.project_id}-subnet" ? data.google_compute_subnetwork.existing_subnet.id : google_compute_subnetwork.subnet[0].id
}

# Cluster GKE com configurações otimizadas
# Verificar se o cluster já existe
data "google_container_cluster" "existing_cluster" {
  name     = "${var.project_id}-cluster"
  location = var.region
}

# Fallback para criar cluster se não existir
resource "google_container_cluster" "primary" {
  count    = data.google_container_cluster.existing_cluster.name == "${var.project_id}-cluster" ? 0 : 1
  name     = "${var.project_id}-cluster"
  location = var.region
  project  = var.project_id

  # DESABILITADO AUTOPILOT - Cluster Standard para controle total
  # enable_autopilot = false  # Removido para usar cluster Standard

  # Configuração de rede
  network    = local.vpc_id
  subnetwork = data.google_compute_subnetwork.existing_subnet.name == "${var.project_id}-subnet" ? data.google_compute_subnetwork.existing_subnet.name : google_compute_subnetwork.subnet[0].name

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
# Verificar se o firewall master já existe
data "google_compute_firewall" "existing_gke_master" {
  name = "gke-master-${var.project_id}"
}

# Fallback para criar firewall master se não existir
resource "google_compute_firewall" "gke_master" {
  count   = data.google_compute_firewall.existing_gke_master.name == "gke-master-${var.project_id}" ? 0 : 1
  name    = "gke-master-${var.project_id}"
  network = local.vpc_id

  allow {
    protocol = "tcp"
    ports    = ["443", "6443"]
  }

  source_ranges = var.allowed_ip_ranges
  target_tags   = ["gke-master"]

  # Tornar reutilizável
  lifecycle {
    create_before_destroy = true
  }
}

# Verificar se o firewall nodes já existe
data "google_compute_firewall" "existing_gke_nodes" {
  name = "gke-nodes-${var.project_id}"
}

# Fallback para criar firewall nodes se não existir
resource "google_compute_firewall" "gke_nodes" {
  count   = data.google_compute_firewall.existing_gke_nodes.name == "gke-nodes-${var.project_id}" ? 0 : 1
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

  # Tornar reutilizável
  lifecycle {
    create_before_destroy = true
  }
}

# 7. Cloud NAT para nós privados
# Verificar se o router já existe
data "google_compute_router" "existing_router" {
  name   = "${var.project_id}-router"
  region = var.region
}

# Fallback para criar router se não existir
resource "google_compute_router" "router" {
  count   = data.google_compute_router.existing_router.name == "${var.project_id}-router" ? 0 : 1
  name    = "${var.project_id}-router"
  region  = var.region
  network = local.vpc_id

  # Tornar reutilizável
  lifecycle {
    create_before_destroy = true
  }
}

# Verificar se o NAT já existe
data "google_compute_router_nat" "existing_nat" {
  name   = "${var.project_id}-nat"
  router = data.google_compute_router.existing_router.name == "${var.project_id}-router" ? data.google_compute_router.existing_router.name : google_compute_router.router[0].name
  region = var.region
}

# Fallback para criar NAT se não existir
resource "google_compute_router_nat" "nat" {
  count                              = data.google_compute_router_nat.existing_nat.name == "${var.project_id}-nat" ? 0 : 1
  name                               = "${var.project_id}-nat"
  router                             = data.google_compute_router.existing_router.name == "${var.project_id}-router" ? data.google_compute_router.existing_router.name : google_compute_router.router[0].name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  # Tornar reutilizável
  lifecycle {
    create_before_destroy = true
  }
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
# Verificar se a Security Policy já existe
data "google_compute_security_policy" "existing_security_policy" {
  name = "security-policy"
}

# Fallback para criar Security Policy se não existir
resource "google_compute_security_policy" "security_policy" {
  count = data.google_compute_security_policy.existing_security_policy.name == "security-policy" ? 0 : 1
  name  = "security-policy"

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
  security_policy_id = data.google_compute_security_policy.existing_security_policy.name == "security-policy" ? data.google_compute_security_policy.existing_security_policy.id : google_compute_security_policy.security_policy[0].id
}

# 15. Cloud KMS para criptografia (REUTILIZÁVEL)
# Verificar se o Key Ring já existe
data "google_kms_key_ring" "existing_keyring" {
  name     = "gke-keyring"
  location = var.region
}

# Fallback para criar Key Ring se não existir
resource "google_kms_key_ring" "keyring" {
  count    = data.google_kms_key_ring.existing_keyring.name == "gke-keyring" ? 0 : 1
  name     = "gke-keyring"
  location = var.region

  # Tornar reutilizável
  lifecycle {
    create_before_destroy = true
  }
}

# Verificar se o Crypto Key já existe
data "google_kms_crypto_key" "existing_key" {
  name     = "gke-key"
  key_ring = data.google_kms_key_ring.existing_keyring.name == "gke-keyring" ? data.google_kms_key_ring.existing_keyring.id : google_kms_key_ring.keyring[0].id
}

# Fallback para criar Crypto Key se não existir
resource "google_kms_crypto_key" "key" {
  count    = data.google_kms_crypto_key.existing_key.name == "gke-key" ? 0 : 1
  name     = "gke-key"
  key_ring = data.google_kms_key_ring.existing_keyring.name == "gke-keyring" ? data.google_kms_key_ring.existing_keyring.id : google_kms_key_ring.keyring[0].id

  lifecycle {
    prevent_destroy       = true
    create_before_destroy = true
  }
}

# Usar Crypto Key existente ou criado
locals {
  crypto_key_id = data.google_kms_crypto_key.existing_key.name == "gke-key" ? data.google_kms_crypto_key.existing_key.id : google_kms_crypto_key.key[0].id
}

# 16. IAM para Cloud KMS
resource "google_kms_crypto_key_iam_member" "crypto_key" {
  crypto_key_id = local.crypto_key_id
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

# 23. APLICAÇÃO KUBERNETES NATIVA (SUBSTITUI CLOUD RUN - MAIS RÁPIDA)
# Aplicação WhoAmI como Deployment Kubernetes
resource "kubernetes_deployment" "whoami_app" {
  metadata {
    name      = "whoami-app"
    namespace = "default"
    labels = {
      app         = "whoami"
      environment = "production"
      managed_by  = "terraform"
      version     = "v1-0-0"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "whoami"
      }
    }

    template {
      metadata {
        labels = {
          app         = "whoami"
          environment = "production"
          managed_by  = "terraform"
          version     = "v1-0-0"
        }
      }

      spec {
        container {
          image = "jwilder/whoami:latest"
          name  = "whoami"

          port {
            container_port = 8000
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "128Mi"
            }
          }

          env {
            name  = "NODE_ENV"
            value = "production"
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 8000
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 8000
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
        }
      }
    }
  }

  depends_on = [data.google_container_cluster.existing_cluster.name == "${var.project_id}-cluster" ? data.google_container_cluster.existing_cluster : google_container_cluster.primary[0]]
}

# Service para expor a aplicação
resource "kubernetes_service" "whoami_app" {
  metadata {
    name      = "whoami-app"
    namespace = "default"
    labels = {
      app         = "whoami"
      environment = "production"
      managed_by  = "terraform"
    }
  }

  spec {
    selector = {
      app = "whoami"
    }

    port {
      port        = 80
      target_port = 8000
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }

  depends_on = [kubernetes_deployment.whoami_app]
}

# Ingress para acesso externo
resource "kubernetes_ingress_v1" "whoami_app" {
  metadata {
    name      = "whoami-app"
    namespace = "default"
    labels = {
      app         = "whoami"
      environment = "production"
      managed_by  = "terraform"
    }
    annotations = {
      "kubernetes.io/ingress.class"                    = "nginx"
      "cert-manager.io/cluster-issuer"                 = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/ssl-redirect"       = "true"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
    }
  }

  spec {
    tls {
      hosts       = [var.domain_name]
      secret_name = "whoami-app-tls"
    }

    rule {
      host = var.domain_name
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.whoami_app.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_service.whoami_app]
}

# 24. CLOUD RUN COMENTADO (MUITO LENTO)
# resource "google_cloud_run_service" "whoami_app" {
#   name     = "whoami-app"
#   location = var.region
# 
#   template {
#     spec {
#       containers {
#         image = "jwilder/whoami:latest"
# 
#         ports {
#           container_port = 8000
#         }
# 
#         resources {
#           limits = {
#             cpu    = "1000m"
#             memory = "512Mi"
#           }
#         }
# 
#         env {
#           name  = "NODE_ENV"
#           value = "production"
#         }
#       }
# 
#       service_account_name = data.google_service_account.gke_node.email
#     }
#   }
# 
#   traffic {
#     percent         = 100
#     latest_revision = true
#   }
# 
#   # Tornar reutilizável - só recria se houver mudanças
#   lifecycle {
#     create_before_destroy = true
#     ignore_changes = [
#       # Ignora mudanças que não afetam a funcionalidade
#       template[0].metadata[0].annotations,
#       template[0].metadata[0].labels
#     ]
#   }
# 
#   # Adicionar tags para identificação
#   metadata {
#     labels = {
#       app         = "whoami"
#       environment = "production"
#       managed_by  = "terraform"
#       version     = "v1-0-0"
#     }
#   }
# }

# 25. Load Balancer para alta disponibilidade (REUTILIZÁVEL - só cria se não existir)
# Verificar se o Health Check já existe
data "google_compute_health_check" "existing_health_check" {
  name = "health-check"
}

# Fallback para criar Health Check se não existir
resource "google_compute_health_check" "default" {
  count = data.google_compute_health_check.existing_health_check.name == "health-check" ? 0 : 1
  name  = "health-check"

  http_health_check {
    port = 8000
  }

  # Tornar reutilizável
  lifecycle {
    create_before_destroy = true
  }
}

# Verificar se o SSL Certificate já existe
data "google_compute_managed_ssl_certificate" "existing_ssl_cert" {
  name = "managed-ssl-certificate"
}

# Fallback para criar SSL Certificate se não existir
resource "google_compute_managed_ssl_certificate" "default" {
  count = data.google_compute_managed_ssl_certificate.existing_ssl_cert.name == "managed-ssl-certificate" ? 0 : 1
  name  = "managed-ssl-certificate"

  managed {
    domains = [var.domain_name]
  }

  # Tornar reutilizável
  lifecycle {
    create_before_destroy = true
  }
}

# Verificar se o DNS Zone já existe
data "google_dns_managed_zone" "existing_dns_zone" {
  name = "default-zone"
}

# Fallback para criar DNS Zone se não existir
resource "google_dns_managed_zone" "default" {
  count       = data.google_dns_managed_zone.existing_dns_zone.name == "default-zone" ? 0 : 1
  name        = "default-zone"
  dns_name    = "${var.domain_name}."
  description = "DNS zone for the project"
}

# 26. DNS para o domínio
resource "google_dns_record_set" "default" {
  name         = "${var.domain_name}."
  managed_zone = data.google_dns_managed_zone.existing_dns_zone.name == "default-zone" ? data.google_dns_managed_zone.existing_dns_zone.name : google_dns_managed_zone.default[0].name
  type         = "A"
  ttl          = 300

  rrdatas = ["8.8.8.8"] # IP temporário - será atualizado pelo Ingress
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
