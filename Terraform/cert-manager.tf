# Cert-Manager e ClusterIssuer para Let's Encrypt
# Este arquivo usa nosso chart Helm personalizado para instalação robusta

# 1. Instalar o cert-manager via chart oficial do Helm
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  create_namespace = true
  version    = "v1.13.3"

  # Aguardar a instalação completa
  wait    = true
  timeout = 1200

  # Dependências
  depends_on = [
    helm_release.ingress_nginx
  ]

  # Valores para instalação
  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "global.leaderElection.namespace"
    value = "cert-manager"
  }
}

# 2. ClusterIssuer para Let's Encrypt (após cert-manager estar instalado)
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

# 3. Outputs para verificação do status
output "cert_manager_status" {
  description = "Status da instalação do cert-manager"
  value       = helm_release.cert_manager.status
}

output "cluster_issuer_status" {
  description = "Status do ClusterIssuer"
  value       = kubernetes_manifest.cluster_issuer.uid
}
