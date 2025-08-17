# Aplicações DevOps e SRE
# Este arquivo automatiza o deploy completo das aplicações

# 1. Verificar se o namespace DevOps existe
data "kubernetes_namespace" "devops" {
  metadata {
    name = "devops"
  }
}

# 2. Verificar se o namespace SRE existe
data "kubernetes_namespace" "sre" {
  metadata {
    name = "sre"
  }
}

# 3. Deployment da aplicação DevOps
resource "kubernetes_deployment" "devops_whoami" {
  metadata {
    name      = "devops-whoami"
    namespace = data.kubernetes_namespace.devops.metadata[0].name
    labels = {
      app = "devops-whoami"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "devops-whoami"
      }
    }

    template {
      metadata {
        labels = {
          app = "devops-whoami"
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
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
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
}

# 4. Deployment da aplicação SRE
resource "kubernetes_deployment" "sre_whoami" {
  metadata {
    name      = "sre-whoami"
    namespace = data.kubernetes_namespace.sre.metadata[0].name
    labels = {
      app = "sre-whoami"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "sre-whoami"
      }
    }

    template {
      metadata {
        labels = {
          app = "sre-whoami"
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
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
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
}

# --- DEVOPS ---
# Verifica se o serviço já existe
data "kubernetes_service" "existing_devops_service" {
  metadata {
    name      = "devops-whoami-service"
    namespace = "devops"
  }
}

resource "kubernetes_service" "devops_whoami_service" {
  count = data.kubernetes_service.existing_devops_service.id == "" ? 1 : 0

  metadata {
    name      = "devops-whoami-service"
    namespace = data.kubernetes_namespace.devops.metadata[0].name
  }

  spec {
    selector = {
      app = "devops-whoami"
    }

    port {
      port        = 80
      target_port = 8000
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }

  depends_on = [kubernetes_deployment.devops_whoami]
}

# --- SRE ---
# Verifica se o serviço já existe
data "kubernetes_service" "existing_sre_service" {
  metadata {
    name      = "sre-whoami-service"
    namespace = "sre"
  }
}

resource "kubernetes_service" "sre_whoami_service" {
  count = data.kubernetes_service.existing_sre_service.id == "" ? 1 : 0

  metadata {
    name      = "sre-whoami-service"
    namespace = data.kubernetes_namespace.sre.metadata[0].name
  }

  spec {
    selector = {
      app = "sre-whoami"
    }

    port {
      port        = 80
      target_port = 8000
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }

  depends_on = [kubernetes_deployment.sre_whoami]
}

# 7. Ingress para DevOps
resource "kubernetes_ingress_v1" "devops_whoami_ingress" {
  metadata {
    name      = "devops-whoami-ingress"
    namespace = data.kubernetes_namespace.devops.metadata[0].name
    annotations = {
      "cert-manager.io/cluster-issuer"                 = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/ssl-redirect"       = "true"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
    }
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = [var.devops_domain]
      secret_name = "devops-whoami-tls-cert"
    }

    rule {
      host = var.devops_domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = data.kubernetes_service.existing_devops_service.id != "" ? data.kubernetes_service.existing_devops_service.metadata[0].name : kubernetes_service.devops_whoami_service[0].metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

# 8. Ingress para SRE
resource "kubernetes_ingress_v1" "sre_whoami_ingress" {
  metadata {
    name      = "sre-whoami-ingress"
    namespace = data.kubernetes_namespace.sre.metadata[0].name
    annotations = {
      "cert-manager.io/cluster-issuer"                 = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/ssl-redirect"       = "true"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
    }
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = [var.sre_domain]
      secret_name = "sre-whoami-tls-cert"
    }

    rule {
      host = var.sre_domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = data.kubernetes_service.existing_sre_service.id != "" ? data.kubernetes_service.existing_sre_service.metadata[0].name : kubernetes_service.sre_whoami_service[0].metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

# 9. Outputs para as aplicações
output "devops_application_url" {
  description = "URL da aplicação DevOps"
  value       = "https://${var.devops_domain}"
  depends_on  = [kubernetes_ingress_v1.devops_whoami_ingress]
}

output "sre_application_url" {
  description = "URL da aplicação SRE"
  value       = "https://${var.sre_domain}"
  depends_on  = [kubernetes_ingress_v1.sre_whoami_ingress]
}

output "devops_namespace" {
  description = "Namespace da aplicação DevOps"
  value       = data.kubernetes_namespace.devops.metadata[0].name
}

output "sre_namespace" {
  description = "Namespace da aplicação SRE"
  value       = data.kubernetes_namespace.sre.metadata[0].name
}
