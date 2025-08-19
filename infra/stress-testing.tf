# Ferramentas de Stress Testing e Performance

# IMPORTANTE: Este arquivo será descomentado após o cluster GKE estar ativo
# Execute: terraform apply para criar apenas a infraestrutura básica
# Depois: Descomente este arquivo e execute novamente para criar os recursos Kubernetes

# 1. K6 para testes de carga e performance
# COMENTADO - será habilitado após cluster estar ativo
# resource "kubernetes_deployment" "k6" {
#   metadata {
#     name      = "k6"
#     namespace = "stress-testing"
#     labels = {
#       app = "k6"
#     }
#   }
#   
#   spec {
#     replicas = 1
#     
#     selector {
#       match_labels = {
#         app = "k6"
#       }
#     }
#     
#     template {
#       metadata {
#         labels = {
#           app = "k6"
#         }
#       }
#       
#       spec {
#         container {
#           name  = "k6"
#           image = "grafana/k6:latest"
#           
#           command = ["k6"]
#           args = [
#             "run",
#             "--out", "influxdb=http://influxdb.stress-testing.svc.cluster.local:8086/k6",
#             "--out", "prometheus=remote-write=http://prometheus-stack-prometheus.monitoring.svc.cluster.local:9090/api/v1/write",
#             "/scripts/load-test.js"
#           ]
#           
#           volume_mount {
#             name       = "scripts"
#             mount_path = "/scripts"
#           }
#           
#           resources {
#             requests = {
#               cpu    = "100m"
#               memory = "128Mi"
#             }
#             limits = {
#               cpu    = "500m"
#               memory = "512Mi"
#             }
#           }
#         }
#         
#         volume {
#           name = "scripts"
#           config_map {
#             name = "k6-scripts"
#           }
#         }
#       }
#     }
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 2. Service para K6
# COMENTADO - será habilitado após cluster estar ativo
# resource "kubernetes_service" "k6" {
#   metadata {
#     name      = "k6"
#     namespace = "stress-testing"
#   }
#   
#   spec {
#     selector = {
#       app = "k6"
#     }
#     
#     port {
#       port        = 8080
#       target_port = 8080
#     }
#     
#     type = "ClusterIP"
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 3. ConfigMap com scripts de teste K6
# COMENTADO - será habilitado após cluster estar ativo
# resource "kubernetes_config_map" "k6_scripts" {
#   metadata {
#     name      = "k6-scripts"
#     namespace = "stress-testing"
#   }
#   
#   data = {
#     "load-test.js" = <<-EOF
#       import http from 'k6/http';
#       import { check, sleep } from 'k6';
#       
#       export const options = {
#         stages: [
#           { duration: '2m', target: 100 }, // Ramp up to 100 users
#           { duration: '5m', target: 100 }, // Stay at 100 users
#           { duration: '2m', target: 0 },   // Ramp down to 0 users
#         ],
#         thresholds: {
#           http_req_duration: ['p(95)<500'], // 95% of requests must complete below 500ms
#           http_req_failed: ['rate<0.1'],    // Error rate must be below 10%
#         },
#       };
#       
#       export default function () {
#         const response = http.get('http://whoami-service.default.svc.cluster.local:8080/');
#         
#         check(response, {
#           'status is 200': (r) => r.status === 200,
#           'response time < 500ms': (r) => r.timings.duration < 500,
#         });
#         
#         sleep(1);
#       }
#     EOF
#     
#     "stress-test.js" = <<-EOF
#       import http from 'k6/http';
#       import { check, sleep } from 'k6';
#       
#       export const options = {
#         stages: [
#           { duration: '1m', target: 50 },  // Ramp up to 50 users
#           { duration: '3m', target: 50 },  // Stay at 50 users
#           { duration: '1m', target: 100 }, // Ramp up to 100 users
#           { duration: '3m', target: 100 }, // Stay at 100 users
#           { duration: '1m', target: 0 },   // Ramp down to 0 users
#         ],
#         thresholds: {
#           http_req_duration: ['p(95)<1000'], // 95% of requests must complete below 1s
#           http_req_failed: ['rate<0.05'],    // Error rate must be below 5%
#         },
#       };
#       
#       export default function () {
#         const response = http.get('http://whoami-service.default.svc.cluster.local:8080/health');
#         
#         check(response, {
#           'status is 200': (r) => r.status === 200,
#           'response time < 1s': (r) => r.timings.duration < 1000,
#         });
#         
#         sleep(2);
#       }
#     EOF
#     
#     "spike-test.js" = <<-EOF
#       import http from 'k6/http';
#       import { check, sleep } from 'k6';
#       
#       export const options = {
#         stages: [
#           { duration: '1m', target: 10 },   // Normal load
#           { duration: '30s', target: 200 }, // Spike to 200 users
#           { duration: '1m', target: 200 },  // Stay at spike
#           { duration: '30s', target: 10 },  // Back to normal
#           { duration: '1m', target: 10 },   // Stabilize
#         ],
#         thresholds: {
#           http_req_duration: ['p(95)<2000'], // 95% of requests must complete below 2s
#           http_req_failed: ['rate<0.2'],     // Error rate must be below 20% during spike
#         },
#       };
#       
#       export default function () {
#         const response = http.get('http://whoami-service.default.svc.cluster.local:8080/');
#         
#         check(response, {
#           'status is 200': (r) => r.status === 200,
#         });
#         
#         sleep(1);
#       }
#     EOF
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 4. InfluxDB para armazenar métricas dos testes
# COMENTADO - será habilitado após cluster estar ativo
# resource "kubernetes_deployment" "influxdb" {
#   metadata {
#     name      = "influxdb"
#     namespace = "stress-testing"
#     labels = {
#       app = "influxdb"
#     }
#   }
#   
#   spec {
#     replicas = 1
#     
#     selector {
#       match_labels = {
#         app = "influxdb"
#       }
#     }
#     
#     template {
#       metadata {
#         labels = {
#           app = "influxdb"
#         }
#       }
#       
#       spec {
#         container {
#           name  = "influxdb"
#           image = "influxdb:2.0"
#           
#           env {
#             name  = "DOCKER_INFLUXDB_INIT_MODE"
#             value = "setup"
#           }
#           
#           env {
#             name  = "DOCKER_INFLUXDB_INIT_USERNAME"
#             value = "admin"
#           }
#           
#           env {
#             name  = "DOCKER_INFLUXDB_INIT_PASSWORD"
#             value = var.influxdb_password
#           }
#           
#           env {
#             name  = "DOCKER_INFLUXDB_INIT_ORG"
#             value = "projeto-sre-devops"
#           }
#           
#           env {
#             name  = "DOCKER_INFLUXDB_INIT_BUCKET"
#             value = "k6"
#           }
#           
#           port {
#             container_port = 8086
#           }
#           
#           resources {
#             requests = {
#               cpu    = "250m"
#               memory = "256Mi"
#             }
#             limits = {
#               cpu    = "500m"
#               memory = "512Mi"
#             }
#           }
#           
#           volume_mount {
#             name       = "influxdb-data"
#             mount_path = "/var/lib/influxdb2"
#           }
#         }
#         
#         volume {
#           name = "influxdb-data"
#           persistent_volume_claim {
#             claim_name = "influxdb-pvc"
#           }
#         }
#       }
#     }
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 5. Service para InfluxDB
# COMENTADO - será habilitado após cluster estar ativo
# resource "kubernetes_service" "influxdb" {
#   metadata {
#     name      = "influxdb"
#     namespace = "stress-testing"
#   }
#   
#   spec {
#     selector = {
#       app = "influxdb"
#     }
#     
#     port {
#       port        = 8086
#       target_port = 8086
#     }
#     
#     type = "ClusterIP"
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 6. PVC para InfluxDB
# COMENTADO - será habilitado após cluster estar ativo
# resource "kubernetes_persistent_volume_claim" "influxdb" {
#   metadata {
#     name      = "influxdb-pvc"
#     namespace = "stress-testing"
#   }
#   
#   spec {
#     access_modes = ["ReadWriteOnce"]
#     resources {
#       requests = {
#         storage = "5Gi"
#       }
#     }
#     storage_class_name = "standard"
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 7. Ingress para K6 e InfluxDB
# COMENTADO - será habilitado após cluster estar ativo
# resource "kubernetes_ingress_v1" "stress_testing" {
#   metadata {
#     name      = "stress-testing-ingress"
#     namespace = "stress-testing"
#     annotations = {
#       "kubernetes.io/ingress.class" = "nginx"
#       "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
#     }
#   }
#   
#   spec {
#     tls {
#       hosts = ["k6.${var.domain_name}."]
#       secret_name = "k6-tls"
#     }
#     
#     rule {
#       host = "k6.${var.domain_name}."
#       http {
#         path {
#           path = "/"
#           path_type = "Prefix"
#           backend {
#             service {
#               name = "k6"
#               port {
#                 number = 8080
#               }
#             }
#           }
#         }
#       }
#     }
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 8. ServiceMonitor para Prometheus
# COMENTADO - será habilitado após cluster estar ativo
# resource "kubernetes_manifest" "stress_test_servicemonitor" {
#   manifest = {
#     apiVersion = "monitoring.coreos.com/v1"
#     kind       = "ServiceMonitor"
#     metadata = {
#       name      = "stress-testing"
#       namespace = "monitoring"
#       labels = {
#         release = "prometheus-stack"
#       }
#     }
#     spec = {
#       selector = {
#         matchLabels = {
#           app = "k6"
#         }
#       }
#       endpoints = [
#         {
#           port = "8080"
#           path = "/metrics"
#         }
#       ]
#     }
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 9. Namespace para stress testing
resource "kubernetes_namespace" "stress_testing" {
  metadata {
    name = "stress-testing"
    labels = {
      name = "stress-testing"
    }
  }

  depends_on = [google_container_cluster.primary]
}

# IMPORTANTE: Este arquivo será descomentado após o cluster GKE estar ativo
# Execute: terraform apply para criar apenas a infraestrutura básica
# Depois: Descomente este arquivo e execute novamente para criar os recursos Kubernetes
