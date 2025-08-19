# 🔄 Pipelines CI/CD

Esta pasta contém os pipelines de CI/CD para automação do projeto.

## 📁 Estrutura

- **`terraform.yml`** - Pipeline Terraform (GitHub Actions)
- **`terraform-cert-manager.yml`** - Pipeline específico para Cert-Manager
- **`cloudbuild.yaml`** - Pipeline Google Cloud Build

## 🚀 Como usar

### GitHub Actions:
Os pipelines são executados automaticamente quando:
- Push para branch `main`
- Pull Request para branch `main`
- Mudanças em arquivos Terraform

### Google Cloud Build:
```bash
gcloud builds submit --config cloudbuild.yaml
```

## 📋 Configuração

### Secrets necessários:
- `GOOGLE_PROJECT_ID`
- `GOOGLE_REGION`
- `GOOGLE_CLUSTER_NAME`
- `WORKLOAD_IDENTITY_PROVIDER`
- `SERVICE_ACCOUNT_EMAIL`
- `GRAFANA_PASSWORD`
- `INFLUXDB_PASSWORD`

## 🔧 Workflows

1. **Terraform** - Deploy de infraestrutura
2. **Cert-Manager** - Gerenciamento de certificados
3. **Cloud Build** - Build e deploy de aplicações
