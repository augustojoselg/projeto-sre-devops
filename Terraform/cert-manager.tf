# ==============================
# 1. Instalação do cert-manager
# ==============================

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = "v1.13.3"

  wait    = true
  timeout = 1200

  depends_on = [
    helm_release.ingress_nginx
  ]

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "global.leaderElection.namespace"
    value = "cert-manager"
  }
}

# ==========================================
# 2. ClusterIssuer - Let's Encrypt Production
# ==========================================

resource "kubernetes_manifest" "letsencrypt_prod" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = "letsencrypt-prod"
    }
    "spec" = {
      "acme" = {
        "email" = var.cert_manager_email
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        "privateKeySecretRef" = {
          "name" = "letsencrypt-prod-private-key"
        }
        "solvers" = [
          {
            "http01" = {
              "ingress" = {
                "class" = "nginx"
              }
            }
          }
        ]
      }
    }
  }

  depends_on = [
    helm_release.cert_manager
  ]
}

# ==============================
# 3. Outputs para verificação
# ==============================

output "cert_manager_version" {
  description = "Versão instalada do cert-manager"
  value       = helm_release.cert_manager.version
}

output "cluster_issuer_production" {
  description = "ClusterIssuer de Produção criado"
  value       = kubernetes_manifest.letsencrypt_prod.manifest["metadata"]["name"]
}
