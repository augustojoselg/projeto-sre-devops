# Projeto SRE DevOps Completo - GCP + Kubernetes + Terraform

## 📋 **Visão Geral**

Este projeto implementa uma solução completa de **Site Reliability Engineering (SRE)** no Google Cloud Platform (GCP), seguindo as melhores práticas de DevOps, segurança e alta disponibilidade. O ambiente é totalmente provisionado via **Infrastructure as Code (IaC)** usando Terraform.

## 🎯 **Objetivos**

- ✅ **Alta Disponibilidade**: Cluster GKE com 1 master e 2 workers
- ✅ **Segurança**: Múltiplas camadas de proteção e compliance
- ✅ **Monitoramento**: Stack completo de observabilidade
- ✅ **APM**: Application Performance Monitoring com Jaeger e Kiali
- ✅ **Logs**: Agregação centralizada com Elasticsearch e Kibana
- ✅ **SSL/TLS**: Certificados automáticos com Let's Encrypt
- ✅ **Testes**: Testes de estresse com K6 e monitoramento integrado
- ✅ **Automação**: CI/CD pipeline completo
- ✅ **Documentação**: README detalhado com explicações técnicas

## 🏗️ **Arquitetura**

### **Infraestrutura GCP**

```
┌─────────────────────────────────────────────────────────────┐
│                    GCP PROJECT                              │
├─────────────────────────────────────────────────────────────┤
│ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────┐   │
│ │   VPC + Subnet  │ │   GKE Cluster   │ │   Cloud    │   │
│ │                 │ │ (1 Master +     │ │  Storage   │   │
│ │ - Flow Logs     │ │  2 Workers)     │ │  + KMS     │   │
│ └─────────────────┘ └─────────────────┘ └─────────────┘   │
├─────────────────────────────────────────────────────────────┤
│ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────┐   │
│ │   Cloud NAT     │ │ Load Balancer   │ │    DNS     │   │
│ │ + Firewall      │ │ + SSL/TLS       │ │ + Domain   │   │
│ └─────────────────┘ └─────────────────┘ └─────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### **Stack de Monitoramento e Observabilidade**

```
┌─────────────────────────────────────────────────────────────┐
│                MONITORING NAMESPACE                        │
├─────────────────────────────────────────────────────────────┤
│ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────┐   │
│ │   Prometheus    │ │     Grafana     │ │AlertManager│   │
│ │   + Metrics     │ │  + Dashboards   │ │  + Rules   │   │
│ └─────────────────┘ └─────────────────┘ └─────────────┘   │
├─────────────────────────────────────────────────────────────┤
│ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────┐   │
│ │     Jaeger      │ │      Kiali      │ │ Fluent Bit │   │
│ │   + Tracing     │ │ + Service Mesh  │ │  + Logs    │   │
│ └─────────────────┘ └─────────────────┘ └─────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### **Stack de Segurança**

```
┌─────────────────────────────────────────────────────────────┐
│                  SECURITY LAYERS                           │
├─────────────────────────────────────────────────────────────┤
│ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────┐   │
│ │  Cert-Manager   │ │   RBAC +        │ │ Network    │   │
│ │  + SSL/TLS      │ │   Policies      │ │ Policies   │   │
│ └─────────────────┘ └─────────────────┘ └─────────────┘   │
├─────────────────────────────────────────────────────────────┤
│ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────┐   │
│ │ Pod Security    │ │   Firewall      │ │   KMS      │   │
│ │ + Standards     │ │ + Rules         │ │+ Encryption│   │
│ └─────────────────┘ └─────────────────┘ └─────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 **Tecnologias Utilizadas**

### **Infraestrutura**
- **Terraform**: Provisionamento de infraestrutura
- **Google Cloud Platform**: Cloud provider
- **Google Kubernetes Engine (GKE)**: Cluster Kubernetes gerenciado
- **VPC**: Rede privada com subnets customizadas

### **Containerização e Orquestração**
- **Kubernetes**: Orquestração de containers
- **Docker**: Containerização de aplicações
- **Helm**: Gerenciamento de charts Kubernetes

### **Monitoramento e Observabilidade**
- **Prometheus**: Coleta e armazenamento de métricas
- **Grafana**: Visualização e dashboards
- **AlertManager**: Gerenciamento de alertas
- **Jaeger**: Distributed tracing (APM)
- **Kiali**: Visualização do service mesh (APM)
- **Elasticsearch + Kibana**: Agregação e análise de logs

### **Segurança**
- **Cert-Manager**: Certificados SSL/TLS automáticos
- **Network Policies**: Controle de tráfego entre pods
- **RBAC**: Controle de acesso baseado em roles
- **Pod Security Standards**: Segurança em nível de pod
- **KMS**: Criptografia de dados sensíveis

### **Ingress e Load Balancing**
- **Nginx Ingress Controller**: Roteamento HTTP/HTTPS
- **Cloud Load Balancer**: Balanceamento de carga global
- **SSL/TLS**: Criptografia em trânsito com Let's Encrypt

### **CI/CD e Automação**
- **Cloud Build**: Pipeline de build automatizado
- **GitHub Actions**: Workflows de CI/CD
- **Cloud Functions**: Automação serverless
- **Cloud Scheduler**: Jobs agendados

## 📁 **Estrutura do Projeto**

```
projeto-sre-devops/
├── 📁 infra/                     # Infraestrutura como Código (Terraform)
│   ├── main.tf                   # Configuração principal
│   ├── variables.tf              # Definição de variáveis
│   ├── terraform.tfvars          # Valores das variáveis
│   ├── versions.tf               # Versões dos providers
│   ├── security-rbac.tf          # Segurança e RBAC
│   ├── firewall.tf               # Regras de firewall
│   ├── applications.tf           # Aplicações Kubernetes
│   ├── prometheus-grafana.tf     # Stack de monitoramento
│   ├── stress-testing.tf         # Testes de estresse
│   └── README.md                 # Documentação da infraestrutura
│
├── 📁 charts/                    # Charts Helm customizados
│   ├── app-chart/                # Chart para aplicações
│   ├── cert-manager-chart/       # Chart para cert-manager
│   ├── devops-values.yaml        # Valores para ambiente DevOps
│   ├── sre-values.yaml           # Valores para ambiente SRE
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
│   ├── terraform.yml             # Pipeline Terraform (GitHub Actions)
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
│   └── README.md                 # Documentação da pasta backup
│
├── REORGANIZACAO-COMPLETA.md     # Histórico da reorganização
├── validate-project.sh            # Script de validação
├── cleanup-old-folders.sh        # Script de limpeza
├── .gitignore                    # Arquivos ignorados pelo Git
├── .gitattributes                # Atributos do Git
└── LICENSE                        # Licença do projeto
```

## 🔧 **Como Usar**

### **Pré-requisitos**
- Google Cloud SDK configurado
- Terraform >= 1.0
- kubectl configurado
- helm >= 3.0

### **Configuração Inicial**

1. **Clone o repositório**:
```bash
git clone https://github.com/augustojoselg/projeto-sre-devops.git
cd projeto-sre-devops
```

2. **Configure as variáveis**:
```bash
cd infra
cp variables.tf.example variables.tf
# Edite variables.tf com seus valores
```

3. **Inicialize o Terraform**:
```bash
terraform init
terraform plan
terraform apply
```

### **Deploy das Aplicações**

1. **Configure o kubectl**:
```bash
gcloud container clusters get-credentials augustosredevops-cluster --region us-west1
```

2. **Deploy do monitoramento**:
```bash
kubectl apply -f infra/prometheus-grafana.tf
```

3. **Deploy das aplicações**:
```bash
kubectl apply -f infra/applications.tf
```

## 🌐 **Acesso aos Serviços**

### **Aplicações Principais**
- **DevOps**: `https://devops.tisl.com.br`
- **SRE**: `https://sre.tisl.com.br`

### **Monitoramento**
- **Grafana**: `https://grafana.tisl.com.br`
  - Usuário: `admin`
  - Senha: Configurada via variável de ambiente
- **Prometheus**: `http://prometheus-stack-prometheus.monitoring.svc.cluster.local:9090`
- **AlertManager**: `http://prometheus-stack-alertmanager.monitoring.svc.cluster.local:9093`

### **APM e Observabilidade**
- **Jaeger**: `https://jaeger.tisl.com.br`
- **Kiali**: `https://kiali.tisl.com.br`

### **Logs e Análise**
- **Kibana**: `https://kibana.tisl.com.br`
- **Elasticsearch**: `http://elasticsearch-master.logging.svc.cluster.local:9200`

### **Testes de Estresse**
- **K6 Metrics**: `http://k6-metrics.stress-testing.svc.cluster.local:5656`

## 📊 **Monitoramento e Alertas**

### **Métricas Coletadas**
- **Infraestrutura**: CPU, memória, disco, rede
- **Aplicação**: Response time, throughput, error rate
- **Kubernetes**: Pod status, node health, resource usage
- **Custom**: Métricas específicas da aplicação

### **Alertas Configurados**
- **Cluster Health**: Pods não saudáveis, nodes offline
- **Performance**: High response time, low throughput
- **Security**: Failed authentication, suspicious activity
- **Resources**: High CPU/memory usage, disk space
- **Availability**: Service downtime, health check failures

### **Dashboards Grafana**
- **DevOps Dashboard**: Métricas específicas para operações DevOps
- **SRE Dashboard**: SLA/SLO e business metrics
- **APM Dashboard**: Performance e distributed tracing
- **Logs Dashboard**: Agregação e análise de logs
- **Stress Testing Dashboard**: Resultados dos testes de estresse

## 🔒 **Segurança**

### **Camadas de Segurança Implementadas**

1. **Network Level**:
   - VPC com subnets isoladas
   - Firewall restrito para IPs corporativos
   - Cloud NAT para saída controlada

2. **Cluster Level**:
   - RBAC granular e específico
   - Network Policies para isolamento entre namespaces
   - Pod Security Standards (restricted/baseline)

3. **Application Level**:
   - SSL/TLS automático com Let's Encrypt
   - Secrets management via Kubernetes
   - Ingress com HTTPS forçado

4. **Infrastructure Level**:
   - KMS encryption para dados sensíveis
   - Service accounts com privilégios mínimos
   - Audit logging habilitado

### **Network Policies Ativas**
- **Default Deny**: Isolamento padrão para todos os namespaces
- **Monitoring Allow**: Acesso controlado ao namespace de monitoramento
- **DevOps/SRE**: Isolamento específico para aplicações
- **APM/Logging**: Isolamento para ferramentas de observabilidade

### **Pod Security Standards**
- **Restricted**: Máximo nível de segurança para produção
- **Baseline**: Nível intermediário para desenvolvimento
- **Audit Mode**: Monitoramento sem enforcement

## 🧪 **Testes de Estresse**

### **Ferramentas Utilizadas**
- **K6**: Testes de performance com JavaScript
- **Cenários Avançados**: Múltiplos cenários de carga
- **Métricas Customizadas**: Taxa de erro, tempo de resposta

### **Cenários de Teste**
1. **Ramp Up**: Aumento gradual da carga (2 min)
2. **Sustained Load**: Carga constante (5 min)
3. **Peak Load**: Pico de carga (2 min)
4. **Ramp Down**: Redução gradual (3 min)

### **Métricas Monitoradas**
- **Response Time**: P50, P95, P99
- **Throughput**: Requests per second
- **Error Rate**: Taxa de erros
- **Resource Usage**: CPU, memória, rede

### **Automação**
- **CronJob**: Execução automática a cada 6 horas
- **Monitoring**: Métricas em tempo real
- **Alerting**: Notificações automáticas
- **Reporting**: Dashboards com resultados

## 🔄 **CI/CD Pipeline**

### **Fluxo do Pipeline**

1. **Code Push**: Trigger automático no GitHub
2. **Infrastructure**: Terraform plan/apply
3. **Application**: Deploy da aplicação
4. **Monitoring**: Deploy do stack de monitoramento
5. **Testing**: Execução de testes de estresse
6. **Health Check**: Verificação de saúde

### **Pipelines Disponíveis**

- **GitHub Actions**: `pipelines/terraform.yml`
- **Cloud Build**: `pipelines/cloudbuild.yaml`
- **Cert-Manager**: `pipelines/terraform-cert-manager.yml`

### **Automações**
- **Backup**: Backup automático diário
- **Security Scan**: Verificação de vulnerabilidades
- **Cleanup**: Limpeza de recursos obsoletos
- **Notifications**: Alertas por email/Slack

## 📈 **Alta Disponibilidade**

### **Estratégias Implementadas**
1. **Multi-Zone**: Distribuição em múltiplas zonas (us-west1-a, us-west1-b, us-west1-c)
2. **Auto-Scaling**: Escalabilidade automática (1-2 nodes por zona)
3. **Load Balancing**: Balanceamento global com health checks
4. **Redundancy**: Múltiplas réplicas de aplicação
5. **Auto-Recovery**: Recuperação automática de falhas

### **SLA Objetivos**
- **Uptime**: 99.9% (8.76 horas de downtime por ano)
- **Recovery Time**: < 5 minutos para falhas simples
- **Data Loss**: 0% (backup automático)
- **Performance**: P95 < 500ms response time

## 💰 **Otimização de Custos**

### **Estratégias de Economia**
1. **Resource Limits**: Limites de recursos para evitar overspending
2. **Auto-Scaling**: Escala para baixo em períodos de baixa demanda
3. **Monitoring**: Alertas de custo em tempo real
4. **Cleanup**: Remoção automática de recursos não utilizados

### **Estimativa de Custos**
- **GKE**: ~$150-300/mês (dependendo do uso)
- **Monitoring**: ~$50-100/mês
- **Storage**: ~$20-50/mês
- **Network**: ~$30-80/mês
- **Total Estimado**: ~$250-530/mês

## 🚨 **Troubleshooting**

### **Problemas Comuns**

#### **Cluster não inicia**
```bash
# Verificar status do cluster
gcloud container clusters describe augustosredevops-cluster --region us-west1

# Verificar logs do master
gcloud logging read "resource.type=gke_cluster" --limit=50
```

#### **Pods não iniciam**
```bash
# Verificar eventos dos pods
kubectl get events --sort-by='.lastTimestamp'

# Verificar logs dos pods
kubectl logs -n <namespace> <pod-name>
```

#### **Problemas de rede**
```bash
# Verificar políticas de rede
kubectl get networkpolicies --all-namespaces

# Verificar configuração do ingress
kubectl describe ingress -n <namespace>
```

#### **Problemas de monitoramento**
```bash
# Verificar status do Prometheus
kubectl get pods -n monitoring

# Verificar logs do Grafana
kubectl logs -f deployment/grafana -n monitoring
```

### **Comandos Úteis**
```bash
# Status geral do cluster
kubectl get all --all-namespaces

# Verificar recursos
kubectl top nodes
kubectl top pods --all-namespaces

# Verificar logs de todos os pods
kubectl logs --all-containers=true --all-namespaces --tail=100

# Verificar eventos
kubectl get events --all-namespaces --sort-by='.lastTimestamp'
```

## 📚 **Recursos Adicionais**

### **Documentação**
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Jaeger Documentation](https://www.jaegertracing.io/docs/)

### **Ferramentas Recomendadas**
- **k9s**: Terminal UI para Kubernetes
- **Lens**: IDE para Kubernetes
- **Octant**: Dashboard para Kubernetes
- **Popeye**: Auditoria de clusters Kubernetes

### **Comunidade**
- [Kubernetes Slack](https://slack.k8s.io/)
- [Terraform Community](https://discuss.hashicorp.com/)
- [Grafana Community](https://community.grafana.com/)

## 🤝 **Contribuição**

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 **Licença**

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 📞 **Suporte**

Para suporte e dúvidas:
- **Issues**: [GitHub Issues](https://github.com/augustojoselg/projeto-sre-devops/issues)
- **Email**: augustojoselg@sysmac-nf.com.br
- **Slack**: #sre-support

---

**Desenvolvido com ❤️ pela equipe de SRE**

## 🔄 **Status do Projeto**

### **✅ Funcionalidades Implementadas e Funcionando**
- ✅ **Infraestrutura GCP**: VPC, GKE, Load Balancer, DNS
- ✅ **Monitoramento**: Prometheus + Grafana + AlertManager
- ✅ **APM Stack**: Jaeger + Kiali com dashboards customizados
- ✅ **Logs Centralizados**: Elasticsearch + Kibana
- ✅ **Segurança**: Network Policies + RBAC + Pod Security Standards
- ✅ **SSL/TLS**: Certificados automáticos com Let's Encrypt
- ✅ **Testes de Estresse**: K6 com cenários avançados
- ✅ **CI/CD**: GitHub Actions + Cloud Build
- ✅ **Documentação**: READMEs específicos para cada componente

### **🎯 Próximos Passos**
- 🎯 **Vault Integration**: Gerenciamento de secrets avançado
- 🎯 **Cloud Armor**: Proteção contra ataques web
- 🎯 **Binary Authorization**: Validação de imagens
- 🎯 **Falco**: Detecção de intrusão em tempo real

---

**Projeto 100% funcional e em produção! 🚀**