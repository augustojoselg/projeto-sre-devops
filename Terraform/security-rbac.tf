# Configurações de Segurança e RBAC

# 1. Network Policies para isolamento de rede
resource "kubernetes_network_policy" "default_deny" {
  metadata {
    name      = "default-deny"
    namespace = "default"
  }
  
  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
  }
  
  depends_on = [google_container_cluster.primary]
}

resource "kubernetes_network_policy" "monitoring_allow" {
  metadata {
    name      = "monitoring-allow"
    namespace = "monitoring"
  }
  
  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
    
    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = "monitoring"
          }
        }
      }
    }
    
    egress {
      to {
        namespace_selector {
          match_labels = {
            name = "monitoring"
          }
        }
      }
    }
  }
  
  depends_on = [google_container_cluster.primary]
}

# 2. Pod Security Policies
resource "kubernetes_pod_security_policy" "restricted" {
  metadata {
    name = "restricted"
  }
  
  spec {
    privileged                 = false
    allow_privilege_escalation = false
    required_drop_capabilities = ["ALL"]
    volumes                    = ["configMap", "emptyDir", "projected", "secret", "downwardAPI", "persistentVolumeClaim"]
    
    run_as_user {
      rule = "MustRunAsNonRoot"
    }
    
    se_linux {
      rule = "RunAsAny"
    }
    
    supplemental_groups {
      rule = "MustRunAs"
    }
    
    fs_group {
      rule = "MustRunAs"
    }
    
    read_only_root_filesystem = true
  }
  
  depends_on = [google_container_cluster.primary]
}

# 3. RBAC - Service Account para aplicações
resource "kubernetes_service_account" "app_sa" {
  metadata {
    name      = "app-service-account"
    namespace = "default"
  }
  
  depends_on = [google_container_cluster.primary]
}

# 4. RBAC - Cluster Role para aplicações
resource "kubernetes_cluster_role" "app_role" {
  metadata {
    name = "app-role"
  }
  
  rule {
    api_groups = [""]
    resources  = ["pods", "services", "endpoints"]
    verbs      = ["get", "list", "watch"]
  }
  
  rule {
    api_groups = [""]
    resources  = ["configmaps", "secrets"]
    verbs      = ["get", "list", "watch"]
  }
  
  depends_on = [google_container_cluster.primary]
}

# 5. RBAC - Cluster Role Binding
resource "kubernetes_cluster_role_binding" "app_role_binding" {
  metadata {
    name = "app-role-binding"
  }
  
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.app_role.metadata[0].name
  }
  
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.app_sa.metadata[0].name
    namespace = kubernetes_service_account.app_sa.metadata[0].namespace
  }
  
  depends_on = [google_container_cluster.primary]
}

# 6. RBAC - Service Account para monitoramento
resource "kubernetes_service_account" "monitoring_sa" {
  metadata {
    name      = "monitoring-service-account"
    namespace = "monitoring"
  }
  
  depends_on = [google_container_cluster.primary]
}

# 7. RBAC - Cluster Role para monitoramento
resource "kubernetes_cluster_role" "monitoring_role" {
  metadata {
    name = "monitoring-role"
  }
  
  rule {
    api_groups = [""]
    resources  = ["nodes", "pods", "services", "endpoints", "namespaces"]
    verbs      = ["get", "list", "watch"]
  }
  
  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }
  
  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["get", "list", "watch", "create", "patch"]
  }
  
  depends_on = [google_container_cluster.primary]
}

# 8. RBAC - Cluster Role Binding para monitoramento
resource "kubernetes_cluster_role_binding" "monitoring_role_binding" {
  metadata {
    name = "monitoring-role-binding"
  }
  
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.monitoring_role.metadata[0].name
  }
  
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.monitoring_sa.metadata[0].name
    namespace = kubernetes_service_account.monitoring_sa.metadata[0].namespace
  }
  
  depends_on = [google_container_cluster.primary]
}

# 9. RBAC - Service Account para logging
resource "kubernetes_service_account" "logging_sa" {
  metadata {
    name      = "logging-service-account"
    namespace = "logging"
  }
  
  depends_on = [google_container_cluster.primary]
}

# 10. RBAC - Cluster Role para logging
resource "kubernetes_cluster_role" "logging_role" {
  metadata {
    name = "logging-role"
  }
  
  rule {
    api_groups = [""]
    resources  = ["pods", "namespaces"]
    verbs      = ["get", "list", "watch"]
  }
  
  rule {
    api_groups = [""]
    resources  = ["pods/log"]
    verbs      = ["get", "list", "watch"]
  }
  
  depends_on = [google_container_cluster.primary]
}

# 11. RBAC - Cluster Role Binding para logging
resource "kubernetes_cluster_role_binding" "logging_role_binding" {
  metadata {
    name = "logging-role-binding"
  }
  
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.logging_role.metadata[0].name
  }
  
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.logging_sa.metadata[0].name
    namespace = kubernetes_service_account.logging_sa.metadata[0].namespace
  }
  
  depends_on = [google_container_cluster.primary]
}

# 12. RBAC - Service Account para tracing
resource "kubernetes_service_account" "tracing_sa" {
  metadata {
    name      = "tracing-service-account"
    namespace = "tracing"
  }
  
  depends_on = [google_container_cluster.primary]
}

# 13. RBAC - Cluster Role para tracing
resource "kubernetes_cluster_role" "tracing_role" {
  metadata {
    name = "tracing-role"
  }
  
  rule {
    api_groups = [""]
    resources  = ["pods", "services", "endpoints"]
    verbs      = ["get", "list", "watch"]
  }
  
  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }
  
  depends_on = [google_container_cluster.primary]
}

# 14. RBAC - Cluster Role Binding para tracing
resource "kubernetes_cluster_role_binding" "tracing_role_binding" {
  metadata {
    name = "tracing-role-binding"
  }
  
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.tracing_role.metadata[0].name
  }
  
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.tracing_sa.metadata[0].name
    namespace = kubernetes_service_account.tracing_sa.metadata[0].namespace
  }
  
  depends_on = [google_container_cluster.primary]
}

# 15. RBAC - Service Account para ingress
resource "kubernetes_service_account" "ingress_sa" {
  metadata {
    name      = "ingress-service-account"
    namespace = "ingress-nginx"
  }
  
  depends_on = [google_container_cluster.primary]
}

# 16. RBAC - Cluster Role para ingress
resource "kubernetes_cluster_role" "ingress_role" {
  metadata {
    name = "ingress-role"
  }
  
  rule {
    api_groups = [""]
    resources  = ["services", "endpoints", "secrets"]
    verbs      = ["get", "list", "watch"]
  }
  
  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses", "ingressclasses"]
    verbs      = ["get", "list", "watch", "update"]
  }
  
  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses/status"]
    verbs      = ["update"]
  }
  
  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["create", "patch"]
  }
  
  depends_on = [google_container_cluster.primary]
}

# 17. RBAC - Cluster Role Binding para ingress
resource "kubernetes_cluster_role_binding" "ingress_role_binding" {
  metadata {
    name = "ingress-role-binding"
  }
  
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.ingress_role.metadata[0].name
  }
  
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.ingress_sa.metadata[0].name
    namespace = kubernetes_service_account.ingress_sa.metadata[0].namespace
  }
  
  depends_on = [google_container_cluster.primary]
}

# 18. RBAC - Service Account para cert-manager
resource "kubernetes_service_account" "cert_manager_sa" {
  metadata {
    name      = "cert-manager-service-account"
    namespace = "cert-manager"
  }
  
  depends_on = [google_container_cluster.primary]
}

# 19. RBAC - Cluster Role para cert-manager
resource "kubernetes_cluster_role" "cert_manager_role" {
  metadata {
    name = "cert-manager-role"
  }
  
  rule {
    api_groups = [""]
    resources  = ["secrets", "events"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
  
  rule {
    api_groups = ["cert-manager.io"]
    resources  = ["certificates", "certificaterequests", "issuers", "clusterissuers"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
  
  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses", "ingresses/status"]
    verbs      = ["get", "list", "watch", "update"]
  }
  
  depends_on = [google_container_cluster.primary]
}

# 20. RBAC - Cluster Role Binding para cert-manager
resource "kubernetes_cluster_role_binding" "cert_manager_role_binding" {
  metadata {
    name = "cert-manager-role-binding"
  }
  
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.cert_manager_role.metadata[0].name
  }
  
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.cert_manager_sa.metadata[0].name
    namespace = kubernetes_service_account.cert_manager_sa.metadata[0].namespace
  }
  
  depends_on = [google_container_cluster.primary]
}

# 21. Security Context para pods
resource "kubernetes_pod" "security_example" {
  metadata {
    name = "security-example"
    labels = {
      app = "security-example"
    }
  }
  
  spec {
    service_account_name = kubernetes_service_account.app_sa.metadata[0].name
    
    security_context {
      run_as_non_root = true
      run_as_user     = 1000
      run_as_group    = 3000
      fs_group        = 2000
    }
    
    container {
      image = "nginx:alpine"
      name  = "nginx"
      
      security_context {
        allow_privilege_escalation = false
        read_only_root_filesystem = true
        capabilities {
          drop = ["ALL"]
        }
      }
      
      port {
        container_port = 80
      }
    }
  }
  
  depends_on = [google_container_cluster.primary]
}

# 22. ConfigMap para políticas de segurança
resource "kubernetes_config_map" "security_policies" {
  metadata {
    name      = "security-policies"
    namespace = "default"
  }
  
  data = {
    "pod-security-policy.yaml" = <<-EOF
      apiVersion: policy/v1beta1
      kind: PodSecurityPolicy
      metadata:
        name: restricted
      spec:
        privileged: false
        allowPrivilegeEscalation: false
        requiredDropCapabilities:
        - ALL
        volumes:
        - 'configMap'
        - 'emptyDir'
        - 'projected'
        - 'secret'
        - 'downwardAPI'
        - 'persistentVolumeClaim'
        runAsUser:
          rule: 'MustRunAsNonRoot'
        seLinux:
          rule: 'RunAsAny'
        supplementalGroups:
          rule: 'MustRunAs'
          ranges:
          - min: 1
            max: 65535
        fsGroup:
          rule: 'MustRunAs'
          ranges:
          - min: 1
            max: 65535
        readOnlyRootFilesystem: true
    EOF
    
    "network-policy.yaml" = <<-EOF
      apiVersion: networking.k8s.io/v1
      kind: NetworkPolicy
      metadata:
        name: default-deny
        namespace: default
      spec:
        podSelector: {}
        policyTypes:
        - Ingress
        - Egress
    EOF
  }
  
  depends_on = [google_container_cluster.primary]
}

# 23. Secret para credenciais sensíveis
resource "kubernetes_secret" "app_secret" {
  metadata {
    name      = "app-secret"
    namespace = "default"
  }
  
  data = {
    username = base64encode("admin")
    password = base64encode("secure-password-123")
    api_key  = base64encode("api-key-456")
  }
  
  type = "Opaque"
  
  depends_on = [google_container_cluster.primary]
}

# 24. ConfigMap para configurações da aplicação
resource "kubernetes_config_map" "app_config" {
  metadata {
    name      = "app-config"
    namespace = "default"
  }
  
  data = {
    "app.properties" = <<-EOF
      # Configurações da aplicação
      app.name=WhoAmI
      app.version=1.0.0
      app.environment=production
      
      # Configurações de segurança
      security.ssl.enabled=true
      security.ssl.verify=true
      security.cors.enabled=true
      security.cors.allowed-origins=*
      
      # Configurações de monitoramento
      monitoring.enabled=true
      monitoring.metrics.enabled=true
      monitoring.tracing.enabled=true
      monitoring.logging.enabled=true
      
      # Configurações de performance
      performance.thread-pool.size=10
      performance.connection-pool.size=20
      performance.cache.enabled=true
      performance.cache.size=1000
    EOF
    
    "logging.properties" = <<-EOF
      # Configurações de logging
      logging.level.root=INFO
      logging.level.com.example=DEBUG
      logging.pattern.console=%d{yyyy-MM-dd HH:mm:ss} - %msg%n
      logging.pattern.file=%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n
      
      # Configurações de arquivo
      logging.file.name=logs/app.log
      logging.file.max-size=100MB
      logging.file.max-history=30
    EOF
  }
  
  depends_on = [google_container_cluster.primary]
}
