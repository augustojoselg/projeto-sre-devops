# 🚀 Projeto SRE DevOps

Infraestrutura como Código (IaC) completa para ambiente SRE DevOps com Kubernetes, Terraform, Helm e monitoramento.

## 📁 Nova Estrutura do Projeto

```
projeto-sre-devops/
├── 📁 infra/                     # Infraestrutura como Código (Terraform)
│   ├── main.tf                   # Configuração principal
│   ├── variables.tf              # Definição de variáveis
│   ├── terraform.tfvars          # Valores das variáveis
│   ├── versions.tf               # Versões dos providers
│   └── README.md                 # Documentação da infraestrutura
│
├── 📁 charts/                    # Charts Helm customizados
│   ├── app-chart/                # Chart para aplicações
│   ├── cert-manager-chart/       # Chart para cert-manager
│   └── README.md                 # Documentação dos charts
│
├── 📁 manifests/                 # Manifests Kubernetes
│   ├── install-all.sh            # Script de instalação completa
│   ├── install-ingress-nginx.sh  # Instalação do Ingress
│   ├── install-cert-manager.sh   # Instalação do Cert-Manager
│   ├── install-monitoring.sh     # Instalação do monitoramento
│   └── README.md                 # Documentação dos manifests
│
├── 📁 pipelines/                 # Pipelines CI/CD
│   ├── terraform.yml             # Pipeline Terraform
│   ├── terraform-cert-manager.yml # Pipeline Cert-Manager
│   ├── cloudbuild.yaml           # Pipeline Google Cloud Build
│   └── README.md                 # Documentação dos pipelines
│
├── 📁 docs/                      # Documentação completa
│   ├── README.md                 # Documentação principal
│   ├── README-VARIAVEIS.md       # Documentação de variáveis
│   ├── README-SECURITY.md        # Configurações de segurança
│   ├── README-APM.md             # Application Performance Monitoring
│   ├── README-LOGS.md            # Stack de logs
│   ├── README-ALERTAS.md         # Sistema de alertas
│   └── README-DOCS.md            # Guia da documentação
│
├── 📁 backup_item/               # Arquivos temporários/backup
│   ├── backup-project.ps1        # Script de backup
│   ├── COMMIT_INSTRUCTIONS.md    # Instruções antigas
│   └── README.md                 # Documentação da pasta backup
│
├── validate-project.sh            # Script de validação
├── cleanup-old-folders.sh        # Script de limpeza
├── REORGANIZACAO-COMPLETA.md     # Este resumo
├── .gitignore                    # Arquivos ignorados pelo Git
├── .gitattributes                # Atributos do Git
└── LICENSE                        # Licença do projeto
```

## 🚀 Início Rápido

### Pré-requisitos
- Terraform >= 1.0
- kubectl configurado
- Helm >= 3.0
- Google Cloud CLI

### Deploy rápido
```bash
# 1. Configurar variáveis
cd infra/
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars com seus valores

# 2. Inicializar Terraform
terraform init

# 3. Aplicar infraestrutura
terraform plan
terraform apply
```

## 📚 Documentação

- **📖 [Documentação Completa](docs/README.md)** - Guia completo
- **⚙️ [Variáveis](docs/README-VARIAVEIS.md)** - Configuração de variáveis
- **🔒 [Segurança](docs/README-SECURITY.md)** - Configurações de segurança
- **📊 [Monitoramento](docs/README-APM.md)** - APM e observabilidade
- **📝 [Logs](docs/README-LOGS.md)** - Stack de logs
- **🚨 [Alertas](docs/README-ALERTAS.md)** - Sistema de alertas

## 🔧 Componentes

### Infraestrutura (Terraform)
- Cluster GKE com alta disponibilidade
- VPC e subnets configuradas
- Firewall e regras de segurança
- Service Accounts e RBAC

### Monitoramento
- Prometheus + Grafana
- Alertas configurados
- Dashboards customizados
- Métricas de aplicação

### Segurança
- Cert-manager com Let's Encrypt
- RBAC configurado
- Network policies
- Secrets management

### CI/CD
- GitHub Actions para Terraform
- Google Cloud Build
- Deploy automático
- Validação de código

## 🚀 Deploy das Aplicações

### Usando Helm
```bash
# Deploy da aplicação DevOps
helm install devops-app ./charts/app-chart -f ./charts/devops-values.yaml

# Deploy da aplicação SRE
helm install sre-app ./charts/app-chart -f ./charts/sre-values.yaml
```

### Usando Manifests
```bash
# Instalação completa
cd manifests/
./install-all.sh
```

## 🔍 Monitoramento

### Acessar Grafana
```bash
kubectl port-forward -n monitoring svc/grafana-external 3000:80
# Abrir http://localhost:3000
# Usuário: admin
# Senha: configurada em terraform.tfvars
```

### Acessar Prometheus
```bash
kubectl port-forward -n monitoring svc/prometheus-external 9090:80
# Abrir http://localhost:9090
```

## 🚨 Alertas

O sistema inclui alertas para:
- CPU e memória alta
- Pods em estado não saudável
- Falhas de deploy
- Problemas de conectividade
- Certificados expirando

## 🔧 Manutenção

### Backup
```powershell
# Backup automático
.\backup_item\backup-project.ps1
```

### Limpeza
```bash
# Limpar recursos antigos
./cleanup-old-folders.sh
```

### Validação
```bash
# Validar projeto
./validate-project.sh
```

## 📞 Suporte

- **Issues**: GitHub Issues
- **Documentação**: [docs/](docs/)
- **Exemplos**: [examples/](examples/)

## 📄 Licença

Este projeto está licenciado sob a [MIT License](LICENSE).

---

**⭐ Se este projeto foi útil, considere dar uma estrela!**