# =============================================================================
# SCRIPT DE BACKUP COMPLETO DO PROJETO SRE-DEVOPS
# =============================================================================
# Este script cria um backup completo do projeto com data e hora
# Autor: Sistema de Backup Automático
# Data: $(Get-Date -Format "dd/MM/yyyy HH:mm:ss")

# Configurações do backup
$ProjectName = "projeto-sre-devops"
$BackupDate = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$BackupFolder = "backup_${ProjectName}_${BackupDate}"
$CurrentDir = Get-Location

Write-Host "INICIANDO BACKUP COMPLETO DO PROJETO SRE-DEVOPS" -ForegroundColor Green
Write-Host "Data/Hora: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor Yellow
Write-Host "Diretorio atual: $CurrentDir" -ForegroundColor Yellow
Write-Host "Pasta de backup: $BackupFolder" -ForegroundColor Yellow
Write-Host ""

# Criar diretório de backup
if (Test-Path $BackupFolder) {
    Remove-Item $BackupFolder -Recurse -Force
}
New-Item -ItemType Directory -Path $BackupFolder | Out-Null
New-Item -ItemType Directory -Path "$BackupFolder/Terraform" | Out-Null
New-Item -ItemType Directory -Path "$BackupFolder/devops" | Out-Null
New-Item -ItemType Directory -Path "$BackupFolder/sre" | Out-Null
New-Item -ItemType Directory -Path "$BackupFolder/Helm" | Out-Null

Write-Host "Diretorios de backup criados" -ForegroundColor Green

# =============================================================================
# BACKUP DOS ARQUIVOS PRINCIPAIS
# =============================================================================
Write-Host "Copiando arquivos principais..." -ForegroundColor Cyan

# Arquivos de configuração Git
Copy-Item ".gitignore" "$BackupFolder/" -Force
Copy-Item ".gitattributes" "$BackupFolder/" -Force
Copy-Item "README.md" "$BackupFolder/" -Force
Copy-Item "LICENSE" "$BackupFolder/" -Force
Copy-Item "cloudbuild.yaml" "$BackupFolder/" -Force

# =============================================================================
# BACKUP DO DIRETÓRIO TERRAFORM
# =============================================================================
Write-Host "Copiando arquivos Terraform..." -ForegroundColor Cyan

# Arquivos Terraform principais
Copy-Item "Terraform/*.tf" "$BackupFolder/Terraform/" -Force
Copy-Item "Terraform/*.md" "$BackupFolder/Terraform/" -Force
Copy-Item "Terraform/*.ps1" "$BackupFolder/Terraform/" -Force
Copy-Item "Terraform/*.yaml" "$BackupFolder/Terraform/" -Force
Copy-Item "Terraform/*.yml" "$BackupFolder/Terraform/" -Force
Copy-Item "Terraform/*.hcl" "$BackupFolder/Terraform/" -Force
Copy-Item "Terraform/*.example" "$BackupFolder/Terraform/" -Force

# Diretório service_account
if (Test-Path "Terraform/service_account") {
    Copy-Item "Terraform/service_account/*" "$BackupFolder/Terraform/service_account/" -Recurse -Force
}

# =============================================================================
# BACKUP DAS APLICAÇÕES
# =============================================================================
Write-Host "Copiando aplicacoes..." -ForegroundColor Cyan

# Aplicação DevOps
if (Test-Path "devops") {
    Copy-Item "devops/*" "$BackupFolder/devops/" -Recurse -Force
}

# Aplicação SRE
if (Test-Path "sre") {
    Copy-Item "sre/*" "$BackupFolder/sre/" -Recurse -Force
}

# =============================================================================
# BACKUP DO HELM
# =============================================================================
Write-Host "Copiando charts Helm..." -ForegroundColor Cyan

if (Test-Path "Helm") {
    Copy-Item "Helm/*" "$BackupFolder/Helm/" -Recurse -Force
}

# =============================================================================
# BACKUP DO ESTADO TERRAFORM (IMPORTANTE!)
# =============================================================================
Write-Host "Copiando estado do Terraform..." -ForegroundColor Cyan

if (Test-Path "Terraform/terraform.tfstate") {
    Copy-Item "Terraform/terraform.tfstate" "$BackupFolder/Terraform/" -Force
    Write-Host "   Estado atual copiado" -ForegroundColor Green
}

if (Test-Path "Terraform/terraform.tfstate.backup") {
    Copy-Item "Terraform/terraform.tfstate.backup" "$BackupFolder/Terraform/" -Force
    Write-Host "   Backup do estado copiado" -ForegroundColor Green
}

# =============================================================================
# BACKUP DE CONFIGURAÇÕES LOCAIS
# =============================================================================
Write-Host "Copiando configuracoes locais..." -ForegroundColor Cyan

# Arquivo de variáveis (se existir)
if (Test-Path "Terraform/terraform.tfvars") {
    Copy-Item "Terraform/terraform.tfvars" "$BackupFolder/Terraform/" -Force
    Write-Host "   Variaveis locais copiadas" -ForegroundColor Green
}

# =============================================================================
# CRIAR ARQUIVO DE METADADOS DO BACKUP
# =============================================================================
Write-Host "Criando metadados do backup..." -ForegroundColor Cyan

$BackupInfo = @"
# =============================================================================
# METADADOS DO BACKUP - PROJETO SRE-DEVOPS
# =============================================================================

Data/Hora do Backup: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')
Versao do PowerShell: $($PSVersionTable.PSVersion)
Sistema Operacional: $($PSVersionTable.OS)
Usuario: $env:USERNAME
Computador: $env:COMPUTERNAME

# =============================================================================
# ESTRUTURA DO PROJETO
# =============================================================================
$(Get-ChildItem -Recurse | Where-Object { !$_.PSIsContainer } | ForEach-Object { $_.FullName.Replace($CurrentDir, "").TrimStart("\") })

# =============================================================================
# ESTADO DO TERRAFORM
# =============================================================================
$(if (Test-Path "Terraform/terraform.tfstate") { "Estado atual: PRESENTE" } else { "Estado atual: AUSENTE" })
$(if (Test-Path "Terraform/terraform.tfstate.backup") { "Backup do estado: PRESENTE" } else { "Backup do estado: AUSENTE" })
$(if (Test-Path "Terraform/terraform.tfvars") { "Variaveis locais: PRESENTE" } else { "Variaveis locais: AUSENTE" })

# =============================================================================
# INSTRUÇÕES DE RESTAURAÇÃO
# =============================================================================
1. Para restaurar o projeto:
   - Copie todos os arquivos de volta para o diretório original
   - Execute: terraform init
   - Execute: terraform plan (para verificar)
   - Execute: terraform apply (se necessário)

2. Para restaurar o estado:
   - Copie terraform.tfstate para o diretório Terraform/
   - Execute: terraform plan (para verificar)

3. Para restaurar variáveis:
   - Copie terraform.tfvars para o diretório Terraform/
   - Ajuste valores conforme necessário

# =============================================================================
# NOTAS IMPORTANTES
# =============================================================================
- Este backup contém TODOS os arquivos do projeto
- Inclui estado do Terraform (importante para restauração)
- Inclui configurações locais (se existirem)
- Mantenha este backup em local seguro
- Teste a restauração em ambiente de desenvolvimento primeiro
"@

$BackupInfo | Out-File -FilePath "$BackupFolder/BACKUP_INFO.md" -Encoding UTF8

# =============================================================================
# CRIAR ARQUIVO COMPRESSO
# =============================================================================
Write-Host "Criando arquivo compactado..." -ForegroundColor Cyan

try {
    # Usar Compress-Archive se disponível (PowerShell 5.0+)
    if ($PSVersionTable.PSVersion.Major -ge 5) {
        Compress-Archive -Path $BackupFolder -DestinationPath "$BackupFolder.zip" -Force
        Write-Host "   Arquivo ZIP criado: $BackupFolder.zip" -ForegroundColor Green
    } else {
        # Fallback para versões mais antigas
        Write-Host "   PowerShell versao antiga, arquivo ZIP nao criado" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   Erro ao criar ZIP: $($_.Exception.Message)" -ForegroundColor Yellow
}

# =============================================================================
# RESUMO FINAL
# =============================================================================
Write-Host ""
Write-Host "BACKUP CONCLUIDO COM SUCESSO!" -ForegroundColor Green
Write-Host ""

# Calcular tamanho do backup
$BackupSize = (Get-ChildItem $BackupFolder -Recurse | Measure-Object -Property Length -Sum).Sum
$BackupSizeMB = [math]::Round($BackupSize / 1MB, 2)

Write-Host "RESUMO DO BACKUP:" -ForegroundColor Yellow
Write-Host "   Pasta: $BackupFolder" -ForegroundColor White
Write-Host "   Tamanho: $BackupSizeMB MB" -ForegroundColor White
Write-Host "   Data: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor White
Write-Host ""

# Listar arquivos principais
Write-Host "ARQUIVOS INCLUIDOS:" -ForegroundColor Yellow
Get-ChildItem $BackupFolder -Recurse | Where-Object { !$_.PSIsContainer } | ForEach-Object {
    $relativePath = $_.FullName.Replace($CurrentDir, "").TrimStart("\")
    Write-Host "   $relativePath" -ForegroundColor White
}

Write-Host ""
Write-Host "ARQUIVOS SENSIVEIS PROTEGIDOS:" -ForegroundColor Yellow
Write-Host "   Estado Terraform (.tfstate)" -ForegroundColor Green
Write-Host "   Variaveis locais (.tfvars)" -ForegroundColor Green
Write-Host "   Configuracoes locais" -ForegroundColor Green

Write-Host ""
Write-Host "PROXIMOS PASSOS:" -ForegroundColor Yellow
Write-Host "   1. Verifique o conteudo da pasta: $BackupFolder" -ForegroundColor White
Write-Host "   2. Teste a restauracao em ambiente de desenvolvimento" -ForegroundColor White
Write-Host "   3. Armazene o backup em local seguro" -ForegroundColor White
Write-Host "   4. Mantenha multiplas versoes de backup" -ForegroundColor White

Write-Host ""
Write-Host "Backup salvo em: $BackupFolder" -ForegroundColor Green
if (Test-Path "$BackupFolder.zip") {
    Write-Host "Arquivo compactado: $BackupFolder.zip" -ForegroundColor Green
}
Write-Host ""
