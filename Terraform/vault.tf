# 1. Namespace para o Vault
resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
  }
}

# 2. Instalação do HashiCorp Vault via Helm
resource "helm_release" "vault" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace  = kubernetes_namespace.vault.metadata[0].name
  version    = "0.27.0" # Versão estável e compatível

  # Configurações via arquivo de valores para manter a organização
  values = [
    "${file("${path.module}/vault-values.yaml")}"
  ]

  depends_on = [
    kubernetes_namespace.vault
  ]
}
