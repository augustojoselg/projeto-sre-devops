# Contas de Serviço e APIs - Configuração

## 📋 Visão Geral

Este documento explica como as contas de serviço estão associadas às APIs habilitadas no projeto `augustosredevops`.

## 🔐 Contas de Serviço Configuradas

### 1. **`devops-sre` (Conta Principal)**
- **Propósito:** Operações DevOps e gerenciamento da infraestrutura
- **Permissões:** Acesso completo às APIs habilitadas
- **Localização:** `service_account/main.tf`

### 2. **`gke-node-sa` (Conta GKE)**
- **Propósito:** Operações dos nós do cluster Kubernetes
- **Permissões:** Acesso específico para operações GKE
- **Localização:** `main.tf`

## 🌐 APIs Habilitadas e Contas Associadas

| API | Serviço | Conta DevOps | Conta GKE | Permissões |
|-----|---------|--------------|-----------|------------|
| `compute.googleapis.com` | Compute Engine | ✅ | ✅ | `compute.admin` |
| `container.googleapis.com` | Kubernetes Engine | ✅ | ✅ | `container.admin` |
| `cloudbuild.googleapis.com` | Cloud Build | ✅ | ❌ | `cloudbuild.builds.builder` |
| `run.googleapis.com` | Cloud Run | ✅ | ❌ | `run.developer` |
| `cloudkms.googleapis.com` | Cloud KMS | ✅ | ❌ | `cloudkms.cryptoKeyEncrypterDecrypter` |
| `dns.googleapis.com` | Cloud DNS | ✅ | ❌ | `dns.admin` |
| `monitoring.googleapis.com` | Cloud Monitoring | ✅ | ✅ | `monitoring.admin` |
| `logging.googleapis.com` | Cloud Logging | ✅ | ✅ | `logging.admin` |
| `iam.googleapis.com` | IAM | ✅ | ❌ | `iam.serviceAccountAdmin` |
| `storage.googleapis.com` | Cloud Storage | ✅ | ✅ | `storage.admin` |

## 🔑 Permissões Detalhadas

### **Conta DevOps (`devops-sre`)**
```hcl
roles = [
  "roles/viewer",                                    # Visualização geral
  "roles/editor",                                    # Edição de recursos
  "roles/compute.admin",                             # Gerenciar Compute Engine
  "roles/container.admin",                           # Gerenciar GKE
  "roles/storage.admin",                             # Gerenciar Cloud Storage
  "roles/cloudbuild.builds.builder",                 # Executar builds
  "roles/run.developer",                             # Gerenciar Cloud Run
  "roles/cloudkms.cryptoKeyEncrypterDecrypter",     # Operações KMS
  "roles/dns.admin",                                 # Gerenciar DNS
  "roles/monitoring.admin",                          # Gerenciar monitoramento
  "roles/logging.admin"                              # Gerenciar logs
]
```

### **Conta GKE Node (`gke-node-sa`)**
```hcl
roles = [
  "roles/container.nodeServiceAccount",              # Operações de nó GKE
  "roles/compute.networkViewer",                     # Visualizar rede
  "roles/storage.objectViewer"                       # Pull de imagens
]
```

## 🚀 Como Funciona

### **1. Habilitação de APIs**
- As APIs são habilitadas via `apis.tf`
- Cada API é habilitada com `google_project_service`

### **2. Associação de Contas**
- As contas de serviço recebem permissões via `google_project_iam_member`
- Cada conta tem acesso específico às APIs necessárias

### **3. Segurança**
- **Princípio do menor privilégio** aplicado
- Cada conta tem apenas as permissões necessárias
- Separação clara entre conta DevOps e conta GKE

## 📁 Arquivos de Configuração

| Arquivo | Propósito |
|---------|-----------|
| `apis.tf` | Habilita as APIs necessárias |
| `service_account/main.tf` | Cria e configura conta DevOps |
| `service_account_apis.tf` | Associa contas às APIs |
| `main.tf` | Cria conta GKE e configura permissões |

## ✅ Verificação

Para verificar se tudo está configurado corretamente:

```bash
# Verificar APIs habilitadas
gcloud services list --enabled --project=augustosredevops

# Verificar permissões da conta DevOps
gcloud projects get-iam-policy augustosredevops \
  --flatten="bindings[].members" \
  --filter="bindings.members:devops-sre@augustosredevops.iam.gserviceaccount.com"

# Verificar permissões da conta GKE
gcloud projects get-iam-policy augustosredevops \
  --flatten="bindings[].members" \
  --filter="bindings.members:gke-node-sa@augustosredevops.iam.gserviceaccount.com"
```

## 🔄 Fluxo de Execução

1. **Terraform habilita as APIs** via `google_project_service`
2. **Cria as contas de serviço** com permissões básicas
3. **Associa as contas às APIs** via `google_project_iam_member`
4. **Configura permissões específicas** para cada serviço

## 🚨 Importante

- **Não delete as contas de serviço** manualmente
- **Use sempre o Terraform** para gerenciar permissões
- **Monitore o uso** das APIs para otimizar custos
- **Revise permissões** regularmente para segurança
