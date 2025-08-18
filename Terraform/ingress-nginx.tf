# Instala o Nginx Ingress Controller a partir do chart Helm oficial.
# Este controlador é responsável por ler os recursos de Ingress do Kubernetes
# e configurar um balanceador de carga para expor os serviços HTTP/HTTPS.
resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "4.10.1" # Versão estável e popular

  # Aguarda a instalação ser concluída antes de prosseguir
  wait = true
}
