# Script para remover recursos Kubernetes do estado do Terraform
# Execute este script para limpar o estado antes de recriar apenas a infraestrutura básica

Write-Host "🔧 Removendo recursos Kubernetes do estado do Terraform..." -ForegroundColor Yellow

# Recursos Helm para remover
$helm_resources = @(
    "helm_release.cert_manager",
    "helm_release.nginx_ingress",
    "helm_release.prometheus_stack"
)

# Recursos Kubernetes para remover
$kubernetes_resources = @(
    "kubernetes_cluster_role.app_role",
    "kubernetes_cluster_role.cert_manager_role",
    "kubernetes_cluster_role.ingress_role",
    "kubernetes_cluster_role.logging_role",
    "kubernetes_cluster_role.monitoring_role",
    "kubernetes_cluster_role.tracing_role",
    "kubernetes_cluster_role_binding.app_role_binding",
    "kubernetes_config_map.app_config",
    "kubernetes_config_map.security_policies",
    "kubernetes_namespace.baseline",
    "kubernetes_namespace.restricted",
    "kubernetes_pod.security_example",
    "kubernetes_secret.app_secret",
    "kubernetes_service_account.app_sa"
)

# Remover recursos Helm
Write-Host "🗑️ Removendo recursos Helm..." -ForegroundColor Cyan
foreach ($resource in $helm_resources) {
    try {
        Write-Host "  Removendo: $resource" -ForegroundColor Gray
        terraform state rm $resource
        Write-Host "  ✅ Removido: $resource" -ForegroundColor Green
    }
    catch {
        Write-Host "  ❌ Erro ao remover: $resource" -ForegroundColor Red
    }
}

# Remover recursos Kubernetes
Write-Host "🗑️ Removendo recursos Kubernetes..." -ForegroundColor Cyan
foreach ($resource in $kubernetes_resources) {
    try {
        Write-Host "  Removendo: $resource" -ForegroundColor Gray
        terraform state rm $resource
        Write-Host "  ✅ Removido: $resource" -ForegroundColor Green
    }
    catch {
        Write-Host "  ❌ Erro ao remover: $resource" -ForegroundColor Red
    }
}

Write-Host "🎯 Recursos removidos com sucesso!" -ForegroundColor Green
Write-Host "📋 Execute agora: terraform plan" -ForegroundColor Cyan
Write-Host "🚀 Depois: terraform apply" -ForegroundColor Cyan
