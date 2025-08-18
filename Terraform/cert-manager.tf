# Cert-Manager e ClusterIssuer para Let's Encrypt
# Este arquivo automatiza a instalação do cert-manager e configuração dos certificados SSL

# 1. Instalar o cert-manager via Helm
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = "v1.13.3"
  
  set {
    name  = "installCRDs"
    value = "true"
  }

  # Aguardar a instalação completa
  wait = true
  timeout = 600

  depends_on = [
    helm_release.ingress_nginx
  ]
}

# 2. ClusterIssuer para Let's Encrypt
resource "kubernetes_manifest" "cluster_issuer" {
  depends_on = [helm_release.cert_manager]

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod"
    }
    spec = {
      acme = {
        email = var.cert_manager_email
        server = "https://acme-v02.api.letsencrypt.org/directory"
        privateKeySecretRef = {
          name = "letsencrypt-prod-key"
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

# 3. Output para verificar a instalação
output "cert_manager_status" {
  description = "Status da instalação do cert-manager"
  value       = helm_release.cert_manager.status
  depends_on  = [helm_release.cert_manager]
}

output "cluster_issuer_status" {
  description = "Status do ClusterIssuer"
  value       = kubernetes_manifest.cluster_issuer.manifest
  depends_on  = [kubernetes_manifest.cluster_issuer]
}
