# Script para habilitar APIs necessárias no projeto GCP
# Execute este script como administrador

Write-Host "=== Habilitando APIs necessárias no projeto GCP ===" -ForegroundColor Green

$projectId = "augustosredevops"

# Lista de APIs para habilitar
$apis = @(
    "compute.googleapis.com",
    "dns.googleapis.com", 
    "cloudkms.googleapis.com",
    "container.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "cloudbuild.googleapis.com",
    "iam.googleapis.com",
    "storage.googleapis.com",
    "secretmanager.googleapis.com"
)

Write-Host "Projeto: $projectId" -ForegroundColor Yellow
Write-Host ""

foreach ($api in $apis) {
    Write-Host "Habilitando API: $api" -ForegroundColor Cyan
    
    try {
        # Tentar usar gcloud se disponível
        $gcloudPath = Get-Command gcloud -ErrorAction SilentlyContinue
        if ($gcloudPath) {
            gcloud services enable $api --project=$projectId --quiet
            Write-Host "  ✓ API $api habilitada via gcloud" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ gcloud não encontrado, use o console GCP" -ForegroundColor Yellow
            $apiName = $api.Split('/')[0]
            $url = "https://console.developers.google.com/apis/api/$apiName/overview?project=$projectId"
            Write-Host "  URL: $url" -ForegroundColor Blue
        }
    }
    catch {
        Write-Host "  ✗ Erro ao habilitar API $api" -ForegroundColor Red
        $apiName = $api.Split('/')[0]
        $url = "https://console.developers.google.com/apis/api/$apiName/overview?project=$projectId"
        Write-Host "  URL manual: $url" -ForegroundColor Blue
    }
}

Write-Host ""
Write-Host "=== APIs que precisam ser habilitadas manualmente ===" -ForegroundColor Yellow
Write-Host "Se o gcloud não funcionar, acesse estas URLs:" -ForegroundColor White
Write-Host ""

foreach ($api in $apis) {
    $apiName = $api.Split('/')[0]
    $url = "https://console.developers.google.com/apis/api/$apiName/overview?project=$projectId"
    Write-Host "$apiName`: $url" -ForegroundColor Blue
}

Write-Host ""
Write-Host "=== Após habilitar as APIs ===" -ForegroundColor Green
Write-Host "1. Aguarde alguns minutos para propagação" -ForegroundColor White
Write-Host "2. Execute: terraform plan" -ForegroundColor White
Write-Host "3. Execute: terraform apply" -ForegroundColor White
Write-Host ""
Write-Host "Pressione qualquer tecla para continuar..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
