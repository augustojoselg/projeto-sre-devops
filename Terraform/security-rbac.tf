# Configurações de Segurança e RBAC

# IMPORTANTE: Este arquivo será descomentado após o cluster GKE estar ativo
# Execute: terraform apply para criar apenas a infraestrutura básica
# Depois: Descomente este arquivo e execute novamente para criar os recursos Kubernetes

# 1. Network Policies para isolamento de rede (COMENTADO - não compatível com GKE Autopilot)
# resource "kubernetes_network_policy" "default_deny" {
#   metadata {
#     name      = "default-deny"
#     namespace = "default"
#   }
#   
#   spec {
#     pod_selector {}
#     policy_types = ["Ingress", "Egress"]
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# resource "kubernetes_network_policy" "monitoring_allow" {
#   metadata {
#     name      = "monitoring-allow"
#     namespace = "monitoring"
#   }
#   
#   spec {
#     pod_selector {}
#     policy_types = ["Ingress", "Egress"]
#     
#     ingress {
#       from {
#         namespace_selector {
#           match_labels = {
#             name = "monitoring"
#           }
#         }
#       }
#     }
#     
#     egress {
#       to {
#         namespace_selector {
#           match_labels = {
#             name = "monitoring"
#           }
#         }
#       }
#     }
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 2. Pod Security Standards (substitui Pod Security Policies deprecated)
# resource "kubernetes_namespace" "restricted" {
#   metadata {
#     name = "restricted"
#     labels = {
#       "pod-security.kubernetes.io/enforce" = "restricted"
#       "pod-security.kubernetes.io/audit"  = "restricted"
#       "pod-security.kubernetes.io/warn"   = "restricted"
#     }
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# resource "kubernetes_namespace" "baseline" {
#   metadata {
#     name = "baseline"
#     labels = {
#       "pod-security.kubernetes.io/enforce" = "baseline"
#       "pod-security.kubernetes.io/audit"  = "baseline"
#       "pod-security.kubernetes.io/warn"   = "baseline"
#     }
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 3. Service Account para aplicações
# resource "kubernetes_service_account" "app_sa" {
#   metadata {
#     name      = "app-service-account"
#     namespace = "default"
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 4. Cluster Role para aplicações
# resource "kubernetes_cluster_role" "app_role" {
#   metadata {
#     name = "app-role"
#   }
#   
#   rule {
#     api_groups = [""]
#     resources  = ["pods", "services", "endpoints"]
#     verbs      = ["get", "list", "watch"]
#   }
#   
#   rule {
#     api_groups = ["apps"]
#     resources  = ["deployments", "replicasets"]
#     verbs      = ["get", "list", "watch"]
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 5. Cluster Role Binding para aplicações
# resource "kubernetes_cluster_role_binding" "app_role_binding" {
#   metadata {
#     name = "app-role-binding"
#   }
#   
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = kubernetes_cluster_role.app_role.metadata[0].name
#   }
#   
#   subject {
#     kind      = "ServiceAccount"
#     name      = kubernetes_service_account.app_sa.metadata[0].name
#     namespace = kubernetes_service_account.app_sa.metadata[0].namespace
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 6. Cluster Role para monitoramento
# resource "kubernetes_cluster_role" "monitoring_role" {
#   metadata {
#     name = "monitoring-role"
#   }
#   
#   rule {
#     api_groups = [""]
#     resources  = ["pods", "services", "endpoints", "nodes"]
#     verbs      = ["get", "list", "watch"]
#   }
#   
#   rule {
#     api_groups = ["metrics.k8s.io"]
#     resources  = ["pods", "nodes"]
#     verbs      = ["get", "list", "watch"]
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 7. Cluster Role Binding para monitoramento
# resource "kubernetes_cluster_role_binding" "monitoring_role_binding" {
#   metadata {
#     name = "monitoring-role-binding"
#   }
#   
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = kubernetes_cluster_role.monitoring_role.metadata[0].name
#   }
#   
#   subject {
#     kind      = "ServiceAccount"
#     name      = "prometheus-k8s"
#     namespace = "monitoring"
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 8. Cluster Role para logging
# resource "kubernetes_cluster_role" "logging_role" {
#   metadata {
#     name = "logging-role"
#   }
#   
#   rule {
#     api_groups = [""]
#     resources  = ["pods", "namespaces"]
#     verbs      = ["get", "list", "watch"]
#   }
#   
#   rule {
#     api_groups = [""]
#     resources  = ["pods/log"]
#     verbs      = ["get", "list", "watch"]
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 9. Cluster Role Binding para logging
# resource "kubernetes_cluster_role_binding" "logging_role_binding" {
#   metadata {
#     name = "logging-role-binding"
#   }
#   
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = kubernetes_cluster_role.logging_role.metadata[0].name
#   }
#   
#   subject {
#     kind      = "ServiceAccount"
#     name      = "fluent-bit"
#     namespace = "monitoring"
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 10. Cluster Role para tracing
# resource "kubernetes_cluster_role" "tracing_role" {
#   metadata {
#     name = "tracing-role"
#   }
#   
#   rule {
#     api_groups = [""]
#     resources  = ["pods", "services"]
#     verbs      = ["get", "list", "watch"]
#   }
#   
#   rule {
#     api_groups = ["networking.k8s.io"]
#     resources  = ["ingresses"]
#     verbs      = ["get", "list", "watch"]
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 11. Cluster Role Binding para tracing
# resource "kubernetes_cluster_role_binding" "tracing_role_binding" {
#   metadata {
#     name = "tracing-role-binding"
#   }
#   
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = kubernetes_cluster_role.tracing_role.metadata[0].name
#   }
#   
#   subject {
#     kind      = "ServiceAccount"
#     name      = "jaeger"
#     namespace = "monitoring"
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 12. Cluster Role para ingress
# resource "kubernetes_cluster_role" "ingress_role" {
#   metadata {
#     name = "ingress-role"
#   }
#   
#   rule {
#     api_groups = [""]
#     resources  = ["services", "endpoints", "secrets"]
#     verbs      = ["get", "list", "watch"]
#   }
#   
#   rule {
#     api_groups = ["networking.k8s.io"]
#     resources  = ["ingresses", "ingressclasses"]
#     verbs      = ["get", "list", "watch", "update", "patch"]
#   }
#   
#   rule {
#     api_groups = ["networking.k8s.io"]
#     resources  = ["ingresses/status"]
#     verbs      = ["update", "patch"]
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 13. Cluster Role Binding para ingress
# resource "kubernetes_cluster_role_binding" "ingress_role_binding" {
#   metadata {
#     name = "ingress-role-binding"
#   }
#   
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = kubernetes_cluster_role.ingress_role.metadata[0].name
#   }
#   
#   subject {
#     kind      = "ServiceAccount"
#     name      = "nginx-ingress-controller"
#     namespace = "ingress-nginx"
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 14. Cluster Role para cert-manager
# resource "kubernetes_cluster_role" "cert_manager_role" {
#   metadata {
#     name = "cert-manager-role"
#   }
#   
#   rule {
#     api_groups = [""]
#     resources  = ["secrets", "events"]
#     verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
#   }
#   
#   rule {
#     api_groups = ["cert-manager.io"]
#     resources  = ["certificates", "certificaterequests", "issuers", "clusterissuers"]
#     verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 15. Cluster Role Binding para cert-manager
# resource "kubernetes_cluster_role_binding" "cert_manager_role_binding" {
#   metadata {
#     name = "cert-manager-role-binding"
#   }
#   
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = kubernetes_cluster_role.cert_manager_role.metadata[0].name
#   }
#   
#   subject {
#     kind      = "ServiceAccount"
#     name      = "cert-manager"
#     namespace = "cert-manager"
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 16. ConfigMap para políticas de segurança
# resource "kubernetes_config_map" "security_policies" {
#   metadata {
#     name      = "security-policies"
#     namespace = "default"
#   }
#   
#   data = {
#     "pod-security-policy.yaml" = <<-EOF
#       # Pod Security Standards (Kubernetes 1.21+)
#       # Aplicar via labels no namespace
#       # pod-security.kubernetes.io/enforce: restricted
#       # pod-security.kubernetes.io/audit: restricted
#       # pod-security.kubernetes.io/warn: restricted
#     EOF
#     
#     "network-policy.yaml" = <<-EOF
#       # Network Policy (COMENTADO - não compatível com GKE Autopilot)
#       # apiVersion: networking.k8s.io/v1
#       # kind: NetworkPolicy
#       # metadata:
#       #   name: default-deny
#       #   namespace: default
#       # spec:
#       #   podSelector: {}
#       #   policyTypes:
#       #   - Ingress
#       #   - Egress
#     EOF
#     
#     "rbac-policy.yaml" = <<-EOF
#       # RBAC Policy
#       # apiVersion: rbac.authorization.k8s.io/v1
#       # kind: ClusterRole
#       # metadata:
#       #   name: security-policy-role
#       # rules:
#       # - apiGroups: [""]
#       #   resources: ["pods", "services"]
#       #   verbs: ["get", "list", "watch"]
#     EOF
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 17. Secret para aplicações
# resource "kubernetes_secret" "app_secret" {
#   metadata {
#     name      = "app-secret"
#     namespace = "default"
#   }
#   
#   type = "Opaque"
#   
#   data = {
#     "database-url" = base64encode("postgresql://user:pass@localhost:5432/db")
#     "api-key"      = base64encode("your-api-key-here")
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# 18. ConfigMap para configurações da aplicação
# resource "kubernetes_config_map" "app_config" {
#   metadata {
#     name      = "app-config"
#     namespace = "default"
#   }
#   
#   data = {
#     "environment" = "production"
#     "log-level"   = "info"
#     "timeout"     = "30s"
#   }
#   
#   depends_on = [google_container_cluster.primary]
# }

# IMPORTANTE: Este arquivo será descomentado após o cluster GKE estar ativo
# Execute: terraform apply para criar apenas a infraestrutura básica
# Depois: Descomente este arquivo e execute novamente para criar os recursos Kubernetes
