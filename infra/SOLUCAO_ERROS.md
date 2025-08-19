# Solução para os Erros do Terraform

## Problemas Identificados

### 1. **APIs não habilitadas no projeto `augustosredevops`**

**Erros:**
- Compute Engine API não habilitada
- Cloud DNS API não habilitada  
- Cloud KMS API não habilitada

**Solução:**
Execute o script PowerShell `enable_apis.ps1` ou habilite manualmente via console GCP:

#### **Opção A: Script PowerShell (Recomendado)**
```powershell
# Execute como administrador
.\enable_apis.ps1
```

#### **Opção B: Console GCP Manual**
Acesse estas URLs e habilite as APIs:

1. **Compute Engine API:**
   https://console.developers.google.com/apis/api/compute.googleapis.com/overview?project=augustosredevops

2. **Cloud DNS API:**
   https://console.developers.google.com/apis/api/dns.googleapis.com/overview?project=augustosredevops

3. **Cloud KMS API:**
   https://console.developers.google.com/apis/api/cloudkms.googleapis.com/overview?project=augustosredevops

4. **Container API (GKE):**
   https://console.developers.google.com/apis/api/container.googleapis.com/overview?project=augustosredevops

5. **Monitoring API:**
   https://console.developers.google.com/apis/api/monitoring.googleapis.com/overview?project=augustosredevops

### 2. **Problemas de Credenciais e Permissões**

**Erro:** "Talvez você precise de credenciais para usar essa API"

**Causas:**
- Não está autenticado no gcloud
- Sem permissões adequadas no projeto
- Billing não ativo
- Política de execução do PowerShell bloqueando gcloud

**Soluções:**

#### **A. Configurar Autenticação gcloud**
```bash
# Fazer login
gcloud auth login

# Configurar projeto
gcloud config set project augustosredevops

# Verificar configuração
gcloud config list
```

#### **B. Resolver Política de Execução PowerShell**
```powershell
# Como administrador
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### **C. Verificar Permissões**
- Confirme que você tem permissão de **Owner** ou **Editor** no projeto
- Verifique se o **billing está ativo**
- Confirme que o projeto existe e está acessível

#### **D. Solução Manual (Recomendada se gcloud falhar)**
Use o script `enable_apis_simple.ps1` que fornece URLs diretas para o console GCP.

### 3. **Problemas de Configuração dos Alertas**

**Erros corrigidos:**
- ✅ Alerta de custo: Adicionada dependência correta
- ✅ Alerta SSL: Adicionado `resource.type="ssl_certificate"`
- ✅ Alerta DNS: Adicionada dependência correta

### 4. **Problema com Service Account**

**Erro:** Provider produziu resultado inconsistente para `google_service_account.gke_node`

**Solução:** Este é um bug conhecido do provider. Execute:
```bash
terraform refresh
terraform plan
```

## Passos para Resolver

### **Passo 1: Resolver Credenciais**
```bash
# Autenticar no gcloud
gcloud auth login

# Configurar projeto
gcloud config set project augustosredevops
```

### **Passo 2: Habilitar APIs**
```powershell
# Execute o script
.\enable_apis_simple.ps1
```

### **Passo 3: Aguardar Propagação**
- Aguarde 5-10 minutos após habilitar as APIs
- As mudanças podem levar tempo para propagar

### **Passo 4: Verificar Status**
```bash
terraform plan
```

### **Passo 5: Aplicar Mudanças**
```bash
terraform apply
```

## APIs Necessárias

| API | Descrição | Status |
|-----|-----------|--------|
| `compute.googleapis.com` | Compute Engine | ❌ Desabilitada |
| `dns.googleapis.com` | Cloud DNS | ❌ Desabilitada |
| `cloudkms.googleapis.com` | Cloud KMS | ❌ Desabilitada |
| `container.googleapis.com` | Kubernetes Engine | ❌ Desabilitada |
| `monitoring.googleapis.com` | Cloud Monitoring | ❌ Desabilitada |
| `logging.googleapis.com` | Cloud Logging | ❌ Desabilitada |
| `cloudbuild.googleapis.com` | Cloud Build | ❌ Desabilitada |
| `iam.googleapis.com` | Identity & Access Management | ❌ Desabilitada |
| `storage.googleapis.com` | Cloud Storage | ❌ Desabilitada |
| `secretmanager.googleapis.com` | Secret Manager | ❌ Desabilitada |

## Verificação de Status

Após habilitar as APIs, verifique o status:

```bash
# Verificar APIs habilitadas
gcloud services list --enabled --project=augustosredevops

# Verificar APIs específicas
gcloud services list --enabled --filter="name:compute.googleapis.com" --project=augustosredevops
```

## Próximos Passos

1. ✅ Resolva credenciais com `gcloud auth login`
2. ✅ Execute `enable_apis_simple.ps1`
3. ⏳ Aguarde propagação (5-10 min)
4. 🔍 Execute `terraform plan`
5. 🚀 Execute `terraform apply`

## Suporte

Se os problemas persistirem:
1. Verifique permissões do projeto
2. Confirme que o billing está ativo
3. Verifique se o projeto existe e está acessível
4. Use o console GCP manual se o gcloud falhar
