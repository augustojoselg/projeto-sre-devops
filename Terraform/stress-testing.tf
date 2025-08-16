# Testes de Estresse com Monitoramento Integrado

# 1. ConfigMap para configurações dos testes de estresse
resource "kubernetes_config_map" "stress_test_config" {
  metadata {
    name      = "stress-test-config"
    namespace = "monitoring"
  }

  data = {
    "k6-script.js" = <<-EOF
      import http from 'k6/http';
      import { check, sleep } from 'k6';
      import { Rate } from 'k6/metrics';

      const errorRate = new Rate('errors');
      const successRate = new Rate('success');

      export const options = {
        stages: [
          { duration: '2m', target: 10 },  // Ramp up
          { duration: '5m', target: 50 },  // Sustained load
          { duration: '2m', target: 100 }, // Peak load
          { duration: '3m', target: 0 },   // Ramp down
        ],
        thresholds: {
          http_req_duration: ['p(95)<500'], // 95% das requisições devem ser < 500ms
          errors: ['rate<0.1'],             // Taxa de erro < 10%
          success: ['rate>0.9'],            // Taxa de sucesso > 90%
        },
      };

      export default function() {
        const response = http.get('http://whoami-service.default.svc.cluster.local:8000');
        
        const success = check(response, {
          'status is 200': (r) => r.status === 200,
          'response time < 500ms': (r) => r.timings.duration < 500,
        });
        
        successRate.add(success);
        errorRate.add(!success);
        
        sleep(1);
      }
    EOF

    "vegeta-script.txt" = <<-EOF
      GET http://whoami-service.default.svc.cluster.local:8000
      Host: whoami-service.default.svc.cluster.local
      User-Agent: Vegeta/1.0
    EOF

    "wrk-script.lua" = <<-EOF
      wrk.method = "GET"
      wrk.headers["Host"] = "whoami-service.default.svc.cluster.local"
      wrk.headers["User-Agent"] = "WRK/1.0"
    EOF
  }
}

# 2. Job de teste de estresse básico com K6
resource "kubernetes_job" "stress_test_k6" {
  metadata {
    name      = "stress-test-k6"
    namespace = "monitoring"
  }

  spec {
    template {
      metadata {
        labels = {
          app = "stress-test-k6"
        }
      }
      spec {
        container {
          name  = "k6"
          image = "grafana/k6:latest"
          
          command = ["k6", "run", "/scripts/k6-script.js"]
          
          volume_mount {
            name       = "scripts"
            mount_path = "/scripts"
          }
          
          env {
            name  = "K6_OUT"
            value = "influxdb=http://prometheus-stack-influxdb.monitoring.svc.cluster.local:8086/k6"
          }
          
          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
        }
        
        volume {
          name = "scripts"
          config_map {
            name = kubernetes_config_map.stress_test_config.metadata[0].name
          }
        }
        
        restart_policy = "Never"
      }
    }
    
    backoff_limit = 3
  }
}

# 3. Job de teste de estresse com Apache Bench
resource "kubernetes_job" "stress_test_ab" {
  metadata {
    name      = "stress-test-ab"
    namespace = "monitoring"
  }

  spec {
    template {
      metadata {
        labels = {
          app = "stress-test-ab"
        }
      }
      spec {
        container {
          name  = "ab"
          image = "httpd:2.4"
          
          command = ["/bin/sh", "-c"]
          args = [
            "apache2-utils && ab -n 1000 -c 10 -t 60 http://whoami-service.default.svc.cluster.local:8000/"
          ]
          
          resources {
            requests = {
              cpu    = "100m"
              memory = "64Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "128Mi"
            }
          }
        }
        
        restart_policy = "Never"
      }
    }
    
    backoff_limit = 3
  }
}

# 4. Job de teste de estresse com WRK
resource "kubernetes_job" "stress_test_wrk" {
  metadata {
    name      = "stress-test-wrk"
    namespace = "monitoring"
  }

  spec {
    template {
      metadata {
        labels = {
          app = "stress-test-wrk"
        }
      }
      spec {
        container {
          name  = "wrk"
          image = "williamyeh/wrk:latest"
          
          command = ["wrk"]
          args = [
            "-t", "4",
            "-c", "100",
            "-d", "60s",
            "--latency",
            "--timeout", "10s",
            "http://whoami-service.default.svc.cluster.local:8000/"
          ]
          
          resources {
            requests = {
              cpu    = "200m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "256Mi"
            }
          }
        }
        
        restart_policy = "Never"
      }
    }
    
    backoff_limit = 3
  }
}

# 5. Job de teste de estresse com Vegeta
resource "kubernetes_job" "stress_test_vegeta" {
  metadata {
    name      = "stress-test-vegeta"
    namespace = "monitoring"
  }

  spec {
    template {
      metadata {
        labels = {
          app = "stress-test-vegeta"
        }
      }
      spec {
        container {
          name  = "vegeta"
          image = "peterevans/vegeta:latest"
          
          command = ["/bin/sh", "-c"]
          args = [
            "echo 'GET http://whoami-service.default.svc.cluster.local:8000/' | vegeta attack -duration=60s -rate=100 | vegeta report"
          ]
          
          resources {
            requests = {
              cpu    = "100m"
              memory = "64Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "128Mi"
            }
          }
        }
        
        restart_policy = "Never"
      }
    }
    
    backoff_limit = 3
  }
}

# 6. CronJob para testes automáticos de estresse
resource "kubernetes_cron_job" "automated_stress_test" {
  metadata {
    name      = "automated-stress-test"
    namespace = "monitoring"
  }

  spec {
    schedule = "0 */6 * * *"  # A cada 6 horas
    
    job_template {
      metadata {
        labels = {
          app = "automated-stress-test"
        }
      }
      
      spec {
        template {
          metadata {
            labels = {
              app = "automated-stress-test"
            }
          }
          spec {
            container {
              name  = "stress-test-runner"
              image = "curlimages/curl:latest"
              
              command = ["/bin/sh", "-c"]
              args = [
                "kubectl create job stress-test-k6 --from=cronjob/automated-stress-test -n monitoring && sleep 300 && kubectl create job stress-test-ab --from=cronjob/automated-stress-test -n monitoring"
              ]
              
              env {
                name  = "KUBECONFIG"
                value = "/root/.kube/config"
              }
              
              volume_mount {
                name       = "kubeconfig"
                mount_path = "/root/.kube"
                read_only  = true
              }
            }
            
            volume {
              name = "kubeconfig"
              secret {
                secret_name = "kubeconfig"
              }
            }
            
            restart_policy = "OnFailure"
          }
        }
      }
    }
  }
}

# 7. Service para visualização dos resultados dos testes
resource "kubernetes_service" "stress_test_results" {
  metadata {
    name      = "stress-test-results"
    namespace = "monitoring"
  }

  spec {
    selector = {
      app = "stress-test-results"
    }

    port {
      port        = 8080
      target_port = 8080
    }

    type = "ClusterIP"
  }
}

# 8. Deployment para visualização dos resultados
resource "kubernetes_deployment" "stress_test_results" {
  metadata {
    name      = "stress-test-results"
    namespace = "monitoring"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "stress-test-results"
      }
    }

    template {
      metadata {
        labels = {
          app = "stress-test-results"
        }
      }

      spec {
        container {
          name  = "results-viewer"
          image = "nginx:alpine"
          
          port {
            container_port = 80
          }
          
          volume_mount {
            name       = "results"
            mount_path = "/usr/share/nginx/html"
          }
        }
        
                  volume {
            name = "results"
            empty_dir {}
          }
      }
    }
  }
}

# 9. Ingress para acesso aos resultados dos testes
resource "kubernetes_ingress_v1" "stress_test_results" {
  metadata {
    name      = "stress-test-results"
    namespace = "monitoring"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }

  spec {
    tls {
      hosts       = ["stress-test.${var.domain_name}"]
      secret_name = "stress-test-tls"
    }

    rule {
      host = "stress-test.${var.domain_name}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.stress_test_results.metadata[0].name
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }
}

# 10. ServiceMonitor para Prometheus coletar métricas dos testes
resource "kubernetes_manifest" "stress_test_servicemonitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "stress-test-monitor"
      namespace = "monitoring"
      labels = {
        "release" = "prometheus-stack"
      }
    }
    spec = {
      selector = {
        matchLabels = {
          app = "stress-test-results"
        }
      }
      endpoints = [
        {
          port = "http"
          path = "/metrics"
          interval = "30s"
        }
      ]
    }
  }
}

# 11. ConfigMap para dashboards do Grafana
resource "kubernetes_config_map" "grafana_dashboards" {
  metadata {
    name      = "grafana-dashboards"
    namespace = "monitoring"
    labels = {
      "grafana_dashboard" = "1"
    }
  }

  data = {
    "stress-test-dashboard.json" = jsonencode({
      dashboard = {
        title = "Stress Test Dashboard"
        panels = [
          {
            title = "Response Time"
            type  = "graph"
            targets = [
              {
                expr = "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))"
              }
            ]
          },
          {
            title = "Request Rate"
            type  = "graph"
            targets = [
              {
                expr = "rate(http_requests_total[5m])"
              }
            ]
          },
          {
            title = "Error Rate"
            type  = "graph"
            targets = [
              {
                expr = "rate(http_requests_total{status=~\"5..\"}[5m])"
              }
            ]
          }
        ]
      }
    })
  }
}
