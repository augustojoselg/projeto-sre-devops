# Prometheus + Grafana para Monitoramento
# Este arquivo configura o stack de monitoramento completo

# 1. Namespace para monitoramento
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      name = "monitoring"
    }
  }

  depends_on = [google_container_cluster.primary]
}

# 2. Helm Release para Prometheus Stack (Kube-Prometheus)
resource "helm_release" "prometheus_stack" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "54.2.0" # Versão mais estável

  # Configurações de timeout e retry
  timeout = 600
  wait    = true

  # Configurações de retry para problemas de conectividade
  max_history   = 0
  force_update  = false
  recreate_pods = false

  # Configurações de dependências
  depends_on = [
    kubernetes_namespace.monitoring,
    google_container_cluster.primary
  ]

  # Configurações do Prometheus
  set {
    name  = "prometheus.prometheusSpec.retention"
    value = "30d" # Retenção de 30 dias
  }

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
    value = "50Gi" # 50GB de storage
  }

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName"
    value = "standard" # Classe de storage padrão do GKE
  }

  # Configurações do Grafana
  set {
    name  = "grafana.adminPassword"
    value = "admin123" # Senha padrão - alterar em produção
  }

  set {
    name  = "grafana.persistence.enabled"
    value = "true"
  }

  set {
    name  = "grafana.persistence.size"
    value = "10Gi"
  }

  # Configurações do AlertManager
  set {
    name  = "alertmanager.alertmanagerSpec.retention"
    value = "120h" # 5 dias de retenção
  }

  set {
    name  = "alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.resources.requests.storage"
    value = "10Gi"
  }

  # Configurações de recursos
  set {
    name  = "prometheus.prometheusSpec.resources.requests.memory"
    value = "2Gi"
  }

  set {
    name  = "prometheus.prometheusSpec.resources.requests.cpu"
    value = "500m"
  }

  set {
    name  = "prometheus.prometheusSpec.resources.limits.memory"
    value = "4Gi"
  }

  set {
    name  = "prometheus.prometheusSpec.resources.limits.cpu"
    value = "1000m"
  }

  set {
    name  = "grafana.resources.requests.memory"
    value = "256Mi"
  }

  set {
    name  = "grafana.resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "grafana.resources.limits.memory"
    value = "512Mi"
  }

  set {
    name  = "grafana.resources.limits.cpu"
    value = "200m"
  }

  # Configurações de segurança
  set {
    name  = "prometheus.prometheusSpec.podSecurityContext.runAsNonRoot"
    value = "true"
  }

  set {
    name  = "prometheus.prometheusSpec.podSecurityContext.runAsUser"
    value = "65534" # nobody
  }

  set {
    name  = "grafana.podSecurityContext.runAsNonRoot"
    value = "true"
  }

  set {
    name  = "grafana.podSecurityContext.runAsUser"
    value = "65534" # nobody
  }

  # Configurações de rede
  set {
    name  = "prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues"
    value = "false"
  }

  set {
    name  = "prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues"
    value = "false"
  }

  # Configurações de scraping
  # Configuração de scraping temporariamente removida para resolver problemas de sintaxe
  # set {
  #   name  = "prometheus.prometheusSpec.additionalScrapeConfigs[0]"
  #   value = <<-EOT
  # - job_name: 'kubernetes-pods'
  #   kubernetes_sd_configs:
  #   - role: pod
  #   relabel_configs:
  #   - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
  #     action: keep
  #     regex: true
  #   - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
  #     action: replace
  #     target_label: __metrics_path__
  #     regex: (.+)
  #   - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
  #     action: replace
  #     regex: ([^:]+)(?::\d+)?;(\d+)
  #     replacement: $1:$2
  #     target_label: __address__
  #   - action: labelmap
  #     regex: __meta_kubernetes_pod_label_(.+)
  #   - source_labels: [__meta_kubernetes_namespace]
  #     action: replace
  #     target_label: kubernetes_namespace
  #   - source_labels: [__meta_kubernetes_pod_name]
  #     action: replace
  #     target_label: kubernetes_pod_name
  # EOT
  # }

  # Lifecycle para evitar destruição acidental

  # Lifecycle para evitar destruição acidental
  lifecycle {
    prevent_destroy = false
  }
}

# 3. Service para acesso ao Grafana
resource "kubernetes_service" "grafana_external" {
  metadata {
    name      = "grafana-external"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    annotations = {
      "cloud.google.com/load-balancer-type" = "External"
    }
  }

  spec {
    selector = {
      "app.kubernetes.io/name"     = "grafana"
      "app.kubernetes.io/instance" = "prometheus"
    }

    port {
      port        = 80
      target_port = 3000
      protocol    = "TCP"
    }

    type = "LoadBalancer"
  }

  depends_on = [helm_release.prometheus_stack]
}

# 4. Service para acesso ao Prometheus
resource "kubernetes_service" "prometheus_external" {
  metadata {
    name      = "prometheus-external"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    annotations = {
      "cloud.google.com/load-balancer-type" = "External"
    }
  }

  spec {
    selector = {
      "app.kubernetes.io/name"     = "prometheus"
      "app.kubernetes.io/instance" = "prometheus"
    }

    port {
      port        = 80
      target_port = 9090
      protocol    = "TCP"
    }

    type = "LoadBalancer"
  }

  depends_on = [helm_release.prometheus_stack]
}

# 5. Service para acesso ao AlertManager
resource "kubernetes_service" "alertmanager_external" {
  metadata {
    name      = "alertmanager-external"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    annotations = {
      "cloud.google.com/load-balancer-type" = "External"
    }
  }

  spec {
    selector = {
      "app.kubernetes.io/name"     = "alertmanager"
      "app.kubernetes.io/instance" = "prometheus"
    }

    port {
      port        = 80
      target_port = 9093
      protocol    = "TCP"
    }

    type = "LoadBalancer"
  }

  depends_on = [helm_release.prometheus_stack]
}

# 6. ConfigMap para dashboards customizados do Grafana
resource "kubernetes_config_map" "grafana_dashboards" {
  metadata {
    name      = "grafana-dashboards"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      "grafana_dashboard" = "1"
    }
  }

  data = {
    "gke-cluster-overview.json" = jsonencode({
      title   = "GKE Cluster Overview"
      type    = "dashboard"
      uid     = "gke-cluster-overview"
      version = 1
      panels = [
        {
          title   = "Cluster CPU Usage"
          type    = "graph"
          gridPos = { h = 8, w = 12, x = 0, y = 0 }
          targets = [
            {
              expr         = "sum(rate(container_cpu_usage_seconds_total{container!=\"\"}[5m])) by (pod)"
              legendFormat = "{{pod}}"
            }
          ]
        },
        {
          title   = "Cluster Memory Usage"
          type    = "graph"
          gridPos = { h = 8, w = 12, x = 12, y = 0 }
          targets = [
            {
              expr         = "sum(rate(container_memory_usage_bytes{container!=\"\"}[5m])) by (pod)"
              legendFormat = "{{pod}}"
            }
          ]
        }
      ]
    })

    "gke-node-metrics.json" = jsonencode({
      title   = "GKE Node Metrics"
      type    = "dashboard"
      uid     = "gke-node-metrics"
      version = 1
      panels = [
        {
          title   = "Node CPU Usage"
          type    = "graph"
          gridPos = { h = 8, w = 12, x = 0, y = 0 }
          targets = [
            {
              expr         = "100 - (avg by (instance) (irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)"
              legendFormat = "{{instance}}"
            }
          ]
        },
        {
          title   = "Node Memory Usage"
          type    = "graph"
          gridPos = { h = 8, w = 12, x = 12, y = 0 }
          targets = [
            {
              expr         = "100 - ((node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100)"
              legendFormat = "{{instance}}"
            }
          ]
        }
      ]
    })
  }

  depends_on = [helm_release.prometheus_stack]
}

# 7. ConfigMap para regras de alerta do Prometheus
resource "kubernetes_config_map" "prometheus_rules" {
  metadata {
    name      = "prometheus-rules"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      "prometheus" = "kube-prometheus"
      "role"       = "alert-rules"
    }
  }

  data = {
    "gke-alerts.yaml" = yamlencode({
      groups = [
        {
          name = "gke-cluster-alerts"
          rules = [
            {
              alert = "HighCPUUsage"
              expr  = "100 - (avg by(instance) (irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100) > 80"
              for   = "5m"
              labels = {
                severity = "warning"
              }
              annotations = {
                summary     = "High CPU usage on {{ $labels.instance }}"
                description = "CPU usage is above 80% for more than 5 minutes"
              }
            },
            {
              alert = "HighMemoryUsage"
              expr  = "100 - ((node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100) > 80"
              for   = "5m"
              labels = {
                severity = "warning"
              }
              annotations = {
                summary     = "High memory usage on {{ $labels.instance }}"
                description = "Memory usage is above 80% for more than 5 minutes"
              }
            },
            {
              alert = "PodRestartingFrequently"
              expr  = "increase(kube_pod_container_status_restarts_total[15m]) > 5"
              for   = "2m"
              labels = {
                severity = "warning"
              }
              annotations = {
                summary     = "Pod {{ $labels.pod }} is restarting frequently"
                description = "Pod has restarted more than 5 times in the last 15 minutes"
              }
            },
            {
              alert = "NodeDown"
              expr  = "up{job=\"kubernetes-nodes\"} == 0"
              for   = "1m"
              labels = {
                severity = "critical"
              }
              annotations = {
                summary     = "Node {{ $labels.instance }} is down"
                description = "Node has been down for more than 1 minute"
              }
            }
          ]
        }
      ]
    })
  }

  depends_on = [helm_release.prometheus_stack]
}

# 8. Outputs para URLs de acesso
output "grafana_url" {
  description = "URL de acesso ao Grafana"
  value       = "http://${kubernetes_service.grafana_external.status[0].load_balancer[0].ingress[0].ip}"
  depends_on  = [kubernetes_service.grafana_external]
}

output "prometheus_url" {
  description = "URL de acesso ao Prometheus"
  value       = "http://${kubernetes_service.prometheus_external.status[0].load_balancer[0].ingress[0].ip}"
  depends_on  = [kubernetes_service.prometheus_external]
}

output "alertmanager_url" {
  description = "URL de acesso ao AlertManager"
  value       = "http://${kubernetes_service.alertmanager_external.status[0].load_balancer[0].ingress[0].ip}"
  depends_on  = [kubernetes_service.alertmanager_external]
}

output "monitoring_credentials" {
  description = "Credenciais de acesso ao Grafana"
  value = {
    username = "admin"
    password = "admin123"
    url      = "http://${kubernetes_service.grafana_external.status[0].load_balancer[0].ingress[0].ip}"
  }
  depends_on = [kubernetes_service.grafana_external]
  sensitive  = true
}
