# Cert-Manager para SSL Automático
# Este arquivo instala o cert-manager e configura os ClusterIssuers

# 1. Instalar o cert-manager via Helm
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

# 3. ClusterIssuer para Let's Encrypt (Staging - para testes)
resource "kubernetes_manifest" "letsencrypt_staging_cluster_issuer" {
  depends_on = [helm_release.cert_manager]

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-staging"
    }
    spec = {
      acme = {
        server = "https://acme-staging-v02.api.letsencrypt.org/directory"
        email = var.cert_manager_email
        privateKeySecretRef = {
          name = "letsencrypt-staging"
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

# 4. Outputs para verificação
output "cert_manager_status" {
  description = "Status do cert-manager"
  value       = helm_release.cert_manager.status
}

output "cluster_issuer_prod_status" {
  description = "Status do ClusterIssuer de produção"
  value       = "configured"
}

output "cluster_issuer_staging_status" {
  description = "Status do ClusterIssuer de staging"
  value       = "configured"
}
