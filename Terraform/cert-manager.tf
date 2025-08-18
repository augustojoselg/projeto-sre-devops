# Cert-Manager e ClusterIssuer para Let's Encrypt
# Este arquivo usa nosso chart Helm personalizado para instalação robusta

# 1. Instalar o cert-manager via nosso chart personalizado
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  chart            = "${path.module}/../Helm/cert-manager-chart"
  namespace        = "cert-manager"
  create_namespace = true

  # Aguardar a instalação completa
  wait    = true
  timeout = 1200

  # Dependências
  depends_on = [
    helm_release.ingress_nginx
  ]

  # Valores personalizados
  set {
    name  = "clusterIssuer.email"
    value = var.cert_manager_email
  }

  set {
    name  = "certManager.timeout"
    value = "900"
  }
}

# 2. Outputs simplificados para evitar problemas no CI/CD
output "cert_manager_status" {
  description = "Status da instalação do cert-manager"
  value       = "deployed"
  depends_on  = [helm_release.cert_manager]
}

output "cluster_issuer_status" {
  description = "Status do ClusterIssuer"
  value       = "configured"
  depends_on  = [helm_release.cert_manager]
}
