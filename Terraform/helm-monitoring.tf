# Helm Charts para Monitoramento e Observabilidade

# 1. Prometheus Stack (Prometheus + Grafana + AlertManager)
# Este é o único stack de monitoramento necessário
resource "helm_release" "prometheus_stack" {
  name       = "prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  create_namespace = true
  
  set {
    name  = "grafana.enabled"
    value = "true"
  }
  
  set {
    name  = "grafana.adminPassword"
    value = "admin123"  # Em produção, usar secret
  }
  
  set {
    name  = "grafana.service.type"
    value = "LoadBalancer"
  }
  
  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
    value = "10Gi"
  }
  
  set {
    name  = "alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.resources.requests.storage"
    value = "5Gi"
  }
  
  set {
    name  = "prometheus.prometheusSpec.retention"
    value = "30d"
  }
  
  set {
    name  = "prometheus.prometheusSpec.scrapeInterval"
    value = "30s"
  }
  
  set {
    name  = "prometheus.prometheusSpec.evaluationInterval"
    value = "30s"
  }
  
  depends_on = [google_container_cluster.primary]
}

# 2. APM - Jaeger para tracing distribuído
resource "helm_release" "jaeger" {
  name       = "jaeger"
  repository = "https://jaegertracing.github.io/helm-charts"
  chart      = "jaeger"
  namespace  = "monitoring"
  create_namespace = false
  
  set {
    name  = "storage.type"
    value = "memory"  # Para desenvolvimento. Em produção usar elasticsearch
  }
  
  set {
    name  = "ingress.enabled"
    value = "true"
  }
  
  set {
    name  = "ingress.className"
    value = "nginx"
  }
  
  set {
    name  = "ingress.hosts[0]"
    value = "jaeger.${var.domain_name}"
  }
  
  depends_on = [google_container_cluster.primary]
}

# 3. APM - Kiali para visualização do service mesh
resource "helm_release" "kiali" {
  name       = "kiali"
  repository = "https://kiali.org/helm-charts"
  chart      = "kiali-server"
  namespace  = "monitoring"
  create_namespace = false
  
  set {
    name  = "auth.strategy"
    value = "anonymous"
  }
  
  set {
    name  = "external_services.grafana.url"
    value = "http://prometheus-stack-grafana.monitoring.svc.cluster.local:80"
  }
  
  set {
    name  = "external_services.grafana.in_cluster_url"
    value = "http://prometheus-stack-grafana.monitoring.svc.cluster.local:80"
  }
  
  set {
    name  = "external_services.tracing.url"
    value = "http://jaeger-query.monitoring.svc.cluster.local:16686"
  }
  
  set {
    name  = "external_services.tracing.in_cluster_url"
    value = "http://jaeger-query.monitoring.svc.cluster.local:16686"
  }
  
  depends_on = [helm_release.prometheus_stack, helm_release.jaeger]
}

# 4. Agregação de Logs - Fluent Bit para coleta centralizada
resource "helm_release" "fluent_bit" {
  name       = "fluent-bit"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  namespace  = "monitoring"
  create_namespace = false
  
  set {
    name  = "config.outputs"
    value = <<-EOF
      [OUTPUT]
          Name            es
          Match           *
          Host            prometheus-stack-elasticsearch-master.monitoring.svc.cluster.local
          Port            9200
          Logstash_Format On
          Logstash_Prefix k8s
          Time_Key        @timestamp
          Generate_ID     On
          Suppress_Type_Name On
          tls             Off
    EOF
  }
  
  depends_on = [helm_release.prometheus_stack]
}

# 5. Cert-manager para gerenciamento de certificados SSL
# Necessário para Let's Encrypt e SSL automático
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  create_namespace = true
  
  set {
    name  = "installCRDs"
    value = "true"
  }
  
  set {
    name  = "global.leaderElection.namespace"
    value = "cert-manager"
  }
  
  depends_on = [google_container_cluster.primary]
}

# 6. Nginx Ingress Controller
# Controlador de ingress principal para roteamento HTTP/HTTPS
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  create_namespace = true
  
  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }
  
  set {
    name  = "controller.resources.requests.cpu"
    value = "100m"
  }
  
  set {
    name  = "controller.resources.requests.memory"
    value = "128Mi"
  }
  
  set {
    name  = "controller.resources.limits.cpu"
    value = "500m"
  }
  
  set {
    name  = "controller.resources.limits.memory"
    value = "512Mi"
  }
  
  set {
    name  = "controller.config.enable-real-ip"
    value = "true"
  }
  
  set {
    name  = "controller.config.use-proxy-protocol"
    value = "true"
  }
  
  depends_on = [google_container_cluster.primary]
}

# 7. Vault para gerenciamento de secrets e keys
resource "helm_release" "vault" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace  = "vault"
  create_namespace = true
  
  set {
    name  = "server.dev.enabled"
    value = "true"
  }
  
  set {
    name  = "server.dev.devRootToken"
    value = "vault-dev-token-12345"
  }
  
  set {
    name  = "server.dev.ha.enabled"
    value = "false"
  }
  
  set {
    name  = "server.ingress.enabled"
    value = "true"
  }
  
  set {
    name  = "server.ingress.ingressClassName"
    value = "nginx"
  }
  
  set {
    name  = "server.ingress.hosts[0].host"
    value = "vault.${var.domain_name}"
  }
  
  set {
    name  = "server.ingress.hosts[0].paths[0].path"
    value = "/"
  }
  
  set {
    name  = "server.ingress.hosts[0].paths[0].pathType"
    value = "Prefix"
  }
  
  depends_on = [google_container_cluster.primary, helm_release.nginx_ingress]
}

# NOTA: Os seguintes serviços foram removidos por serem redundantes:
# - Elasticsearch/Kibana/Filebeat: O GKE já fornece logging nativo
# - Istio: Já configurado no cluster GKE via addons
# - Loki/Promtail: Alternativa ao ELK, mas não necessária inicialmente
# - Grafana Agent: Redundante com o kube-prometheus-stack
# - Node Exporter: Já incluído no kube-prometheus-stack
# - cAdvisor: Já incluído no kube-prometheus-stack
