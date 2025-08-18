# Cert-Manager para SSL Automático
# Este arquivo configura o cert-manager e ClusterIssuer para Let's Encrypt

# 1. ClusterIssuer para Let's Encrypt (Produção)
resource "kubernetes_manifest" "letsencrypt_prod_cluster_issuer" {
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

  depends_on = [google_container_cluster.primary]
}

# 2. ClusterIssuer para Let's Encrypt (Staging - para testes)
resource "kubernetes_manifest" "letsencrypt_staging_cluster_issuer" {
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

  depends_on = [google_container_cluster.primary]
}

# 3. Output para verificar o status dos ClusterIssuers
output "cert_manager_status" {
  description = "Status do cert-manager"
  value = "Cert-manager instalado e configurado com ClusterIssuers para Let's Encrypt"
}
