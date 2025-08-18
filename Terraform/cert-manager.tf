# Cert-Manager para SSL Automático
# Versão simplificada para evitar problemas de parsing

# 1. Instalar o cert-manager via Helm
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  create_namespace = true
  version    = "v1.13.3"

  wait    = true
  timeout = 1200

  depends_on = [
    helm_release.ingress_nginx
  ]

  set {
    name  = "installCRDs"
    value = "true"
  }
}

# 2. ClusterIssuer para Let's Encrypt (Produção)
resource "kubernetes_manifest" "letsencrypt_prod_cluster_issuer" {
  depends_on = [helm_release.cert_manager]

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email = var.cert_manager_email
        privateKeySecretRef = {
          name = "letsencrypt-prod"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                class = "nginx"
              }
            }
          }
        ]
      }
    }
  }
}

# 3. Outputs simples
output "cert_manager_installed" {
  description = "Cert-manager instalado"
  value       = "true"
}

output "cluster_issuer_configured" {
  description = "ClusterIssuer configurado"
  value       = "true"
}
