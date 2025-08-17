# Projeto SRE Completo - GCP + Kubernetes + Terraform

## 📋 **Visão Geral**

Este projeto implementa uma solução completa de **Site Reliability Engineering (SRE)** no Google Cloud Platform (GCP), seguindo as melhores práticas de DevOps, segurança e alta disponibilidade. O ambiente é totalmente provisionado via **Infrastructure as Code (IaC)** usando Terraform.

## 🎯 **Objetivos**

- ✅ **Alta Disponibilidade**: Cluster GKE com 1 master e 2 workers
- ✅ **Segurança**: Múltiplas camadas de proteção e compliance
- ✅ **Monitoramento**: Stack completo de observabilidade
- ✅ **APM**: Application Performance Monitoring com Jaeger e Kiali
- ✅ **Logs**: Agregação centralizada com Fluent Bit
- ✅ **Secrets**: Gerenciamento seguro com HashiCorp Vault
- ✅ **Testes**: Testes de estresse com monitoramento integrado
- ✅ **Automação**: CI/CD pipeline completo
- ✅ **Documentação**: README detalhado com explicações técnicas

## 🏗️ **Arquitetura**

### **Infraestrutura GCP**
```
┌─────────────────────────────────────────────────────────────┐
│                    GCP PROJECT                              │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │   VPC + Subnet  │  │   GKE Cluster   │  │   Cloud     │ │
│  │                 │  │  (1 Master +    │  │   Storage   │ │
│  │   - Flow Logs   │  │   2 Workers)    │  │   + KMS     │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │   Cloud NAT     │  │   Load Balancer │  │   DNS       │ │
│  │   + Firewall    │  │   + SSL         │  │   + Domain  │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### **Stack de Monitoramento e Observabilidade**
```
┌─────────────────────────────────────────────────────────────┐
│                MONITORING NAMESPACE                        │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │ Prometheus      │  │   Grafana       │  │ AlertManager│ │
│  │ + Metrics       │  │ + Dashboards    │  │ + Rules     │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │   Jaeger        │  │     Kiali       │  │  Fluent Bit │ │
│  │ + Tracing       │  │ + Service Mesh  │  │ + Logs      │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### **Stack de Segurança**
```
┌─────────────────────────────────────────────────────────────┐
│                SECURITY LAYERS                             │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │   Vault         │  │   Cert-Manager   │  │   RBAC      │ │
│  │ + Secrets       │  │ + SSL/TLS        │  │ + Policies  │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │ Network Policy  │  │ Pod Security    │  │ Cloud Armor │ │
│  │ + Firewall      │  │ + Admission     │  │ + WAF       │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
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
- **Fluent Bit**: Agregação de logs

### **Segurança**
- **HashiCorp Vault**: Gerenciamento de secrets e keys
- **Cert-Manager**: Certificados SSL/TLS automáticos
- **Network Policies**: Controle de tráfego entre pods
- **RBAC**: Controle de acesso baseado em roles
- **Cloud Armor**: Proteção contra ataques web

### **Ingress e Load Balancing**
- **Nginx Ingress Controller**: Roteamento HTTP/HTTPS
- **Cloud Load Balancer**: Balanceamento de carga global
- **SSL/TLS**: Criptografia em trânsito

### **CI/CD e Automação**
- **Cloud Build**: Pipeline de build automatizado
- **Cloud Functions**: Automação serverless
- **Cloud Scheduler**: Jobs agendados
- **GitHub Integration**: Triggers automáticos

## 📁 **Estrutura do Projeto**

```
projeto-sre-devops/
├── Terraform/                          # Configurações Terraform
│   ├── main.tf                        # Infraestrutura principal
│   ├── helm-monitoring.tf             # Stack de monitoramento
│   ├── security-rbac.tf               # Segurança e RBAC
│   ├── stress-testing.tf              # Testes de estresse
│   ├── cicd-pipeline.tf               # Pipeline CI/CD
│   ├── variables.tf                    # Variáveis
│   ├── outputs.tf                      # Outputs
│   └── service_account/                # Contas de serviço
├── devops/                             # Manifests Kubernetes
├── sre/                                # Configurações SRE
├── ingress-nginx-controller/           # Controlador Nginx
├── cloudbuild.yaml                     # Pipeline Cloud Build
└── README.md                           # Documentação
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
   cd Terraform
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
   gcloud container clusters get-credentials <cluster-name> --region <region>
   ```

2. **Deploy do monitoramento**:
   ```bash
   kubectl apply -f Terraform/helm-monitoring.tf
   ```

3. **Deploy das aplicações**:
   ```bash
   kubectl apply -f devops/
   kubectl apply -f sre/
   ```

## 🌐 **Acesso aos Serviços**

### **Aplicação Principal**
- **URL**: `https://<domain-name>`
- **Health Check**: `https://<domain-name>/health`

### **Monitoramento**
- **Grafana**: `http://<grafana-service-ip>:3000`
  - Usuário: `seu usuario`
  - Senha: `sua senha`
- **Prometheus**: `http://<prometheus-service-ip>:9090`
- **AlertManager**: `http://<alertmanager-service-ip>:9093`

### **APM e Observabilidade**
- **Jaeger**: `https://jaeger.<domain-name>`
- **Kiali**: `http://<kiali-service-ip>:20001`

### **Secrets Management**
- **Vault**: `https://vault.<domain-name>`
  - Token: `seu token`

### **Testes de Estresse**
- **Resultados**: `https://stress-test.<domain-name>`

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
- **Cluster Overview**: Visão geral do cluster
- **Application Metrics**: Métricas da aplicação
- **Infrastructure**: Recursos de infraestrutura
- **Security**: Logs de segurança e auditoria
- **Stress Test**: Resultados dos testes de estresse

## 🔒 **Segurança**

### **Camadas de Segurança**
1. **Network Level**: VPC, subnets, firewall rules
2. **Cluster Level**: RBAC, network policies, pod security
3. **Application Level**: Secrets management, SSL/TLS
4. **Infrastructure Level**: Cloud Armor, KMS encryption

### **Compliance**
- **GDPR**: Logs e dados anonimizados
- **SOC 2**: Auditoria e monitoramento
- **ISO 27001**: Gestão de segurança da informação
- **PCI DSS**: Proteção de dados sensíveis

### **Vault Integration**
- **Secrets**: Credenciais de banco, API keys
- **Keys**: Chaves de criptografia
- **Certificates**: Certificados SSL/TLS
- **Dynamic Secrets**: Geração automática de credenciais

## 🧪 **Testes de Estresse**

### **Ferramentas Utilizadas**
- **K6**: Testes de performance com JavaScript
- **Apache Bench (ab)**: Testes de carga básicos
- **WRK**: Testes de alta concorrência
- **Vegeta**: Testes de taxa constante

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

### **Automações**
- **Backup**: Backup automático diário
- **Security Scan**: Verificação de vulnerabilidades
- **Cleanup**: Limpeza de recursos obsoletos
- **Notifications**: Alertas por email/Slack

## 📈 **Alta Disponibilidade**

### **Estratégias Implementadas**
1. **Multi-Zone**: Distribuição em múltiplas zonas
2. **Auto-Scaling**: Escalabilidade automática (2-5 nodes)
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
1. **Spot Instances**: Uso de instâncias spot quando possível
2. **Auto-Scaling**: Escala para baixo em períodos de baixa demanda
3. **Resource Limits**: Limites de recursos para evitar overspending
4. **Monitoring**: Alertas de custo em tempo real
5. **Cleanup**: Remoção automática de recursos não utilizados

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
gcloud container clusters describe <cluster-name> --region <region>

# Verificar logs do master
gcloud logging read "resource.type=gke_cluster" --limit=50
```

#### **Pods não iniciam**
```bash
# Verificar eventos dos pods
kubectl get events --sort-by='.lastTimestamp'

# Verificar logs dos pods
kubectl logs <pod-name> -n <namespace>
```

#### **Problemas de rede**
```bash
# Verificar políticas de rede
kubectl get networkpolicies --all-namespaces

# Verificar configuração do ingress
kubectl describe ingress <ingress-name> -n <namespace>
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
- [Vault Documentation](https://www.vaultproject.io/docs/)

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
- **Issues**: [GitHub Issues](https://github.com/username/repo/issues)
- **Email**: augustojoselg@sysmac-nf.com.br
- **Slack**: #sre-support

---

**Desenvolvido com ❤️ pela equipe de SRE**
