# Script simplificado para habilitar APIs GCP
# Execute este script como administrador

Write-Host "=== Solução para APIs GCP ===" -ForegroundColor Green
Write-Host ""

$projectId = "augustosredevops"

Write-Host "Projeto: $projectId" -ForegroundColor Yellow
Write-Host ""

Write-Host "=== PROBLEMA IDENTIFICADO ===" -ForegroundColor Red
Write-Host "Você precisa de credenciais e permissões para habilitar APIs" -ForegroundColor White
Write-Host ""

Write-Host "=== SOLUÇÕES ===" -ForegroundColor Green
Write-Host ""

Write-Host "1. CONFIGURAR CREDENCIAIS:" -ForegroundColor Cyan
Write-Host "   - Abra o terminal como administrador" -ForegroundColor White
Write-Host "   - Execute: gcloud auth login" -ForegroundColor White
Write-Host "   - Faça login na sua conta Google" -ForegroundColor White
Write-Host ""

Write-Host "2. CONFIGURAR PROJETO:" -ForegroundColor Cyan
Write-Host "   - Execute: gcloud config set project $projectId" -ForegroundColor White
Write-Host ""

Write-Host "3. VERIFICAR PERMISSÕES:" -ForegroundColor Cyan
Write-Host "   - Confirme que você tem permissão de 'Owner' ou 'Editor'" -ForegroundColor White
Write-Host "   - Verifique se o billing está ativo" -ForegroundColor White
Write-Host ""

Write-Host "=== URLs MANUAIS (se gcloud não funcionar) ===" -ForegroundColor Yellow
Write-Host ""

$apis = @(
    @{Name="Compute Engine"; API="compute.googleapis.com"},
    @{Name="Cloud DNS"; API="dns.googleapis.com"},
    @{Name="Cloud KMS"; API="cloudkms.googleapis.com"},
    @{Name="Kubernetes Engine"; API="container.googleapis.com"},
    @{Name="Cloud Monitoring"; API="monitoring.googleapis.com"},
    @{Name="Cloud Logging"; API="logging.googleapis.com"},
    @{Name="Cloud Build"; API="cloudbuild.googleapis.com"},
    @{Name="IAM"; API="iam.googleapis.com"},
    @{Name="Cloud Storage"; API="storage.googleapis.com"},
    @{Name="Secret Manager"; API="secretmanager.googleapis.com"}
)

foreach ($api in $apis) {
    $url = "https://console.developers.google.com/apis/api/$($api.API)/overview?project=$projectId"
    Write-Host "$($api.Name):" -ForegroundColor Cyan
    Write-Host "  $url" -ForegroundColor Blue
    Write-Host ""
}

Write-Host "=== PASSOS MANUAIS ===" -ForegroundColor Green
Write-Host "1. Acesse cada URL acima" -ForegroundColor White
Write-Host "2. Clique em 'ENABLE' para cada API" -ForegroundColor White
Write-Host "3. Aguarde 5-10 minutos para propagação" -ForegroundColor White
Write-Host "4. Execute: terraform plan" -ForegroundColor White
Write-Host ""

Write-Host "Pressione qualquer tecla para continuar..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
