# 🚀 Monitoramento com Prometheus + Grafana

## **📋 Visão Geral**

Substituímos o Cloud Monitoring do Google por um stack completo de monitoramento open-source:

- **Prometheus**: Coleta e armazena métricas
- **Grafana**: Dashboards e visualizações
- **AlertManager**: Gerenciamento de alertas
- **Node Exporter**: Métricas dos nós
- **Kube State Metrics**: Métricas do Kubernetes

## **🎯 Vantagens da Migração**

### ✅ **Antes (Cloud Monitoring)**
- Custo por métrica coletada
- Dashboards limitados
- Alertas básicos
- Dependência do Google Cloud
- Menos flexibilidade

### 🚀 **Depois (Prometheus + Grafana)**
- **Zero custo** para métricas
- Dashboards **100% customizáveis**
- Alertas **avançados** com PromQL
- **Independente** de cloud provider
- **Totalmente flexível**

## **🏗️ Arquitetura**

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GKE Cluster   │    │   Prometheus    │    │     Grafana     │
│                 │    │                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │ Node Exporter│◄────┤ │ Scraping    │ │    │ │ Dashboards  │ │
│ └─────────────┘ │    │ │ Storage     │ │    │ │ Visualize   │ │
│                 │    │ │ Alerting    │ │    │ │ Configure   │ │
│ ┌─────────────┐ │    │ └─────────────┘ │    │ └─────────────┘ │
│ │Kube State   │◄────┤                 │    │                 │
│ │Metrics      │ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ └─────────────┘ │    │ │AlertManager │ │    │ │   Alerts    │ │
└─────────────────┘    │ └─────────────┘ │    │ └─────────────┘ │
                       └─────────────────┘    └─────────────────┘
```

## **📊 Métricas Coletadas**

### **1. Métricas do Cluster**
- CPU e Memory por nó
- Status dos pods
- Restarts de containers
- Network I/O
- Disk usage

### **2. Métricas da Aplicação**
- Request rate
- Response time
- Error rate
- Resource utilization
- Custom metrics

### **3. Métricas de Infraestrutura**
- Node health
- Pod scheduling
- Service endpoints
- Ingress status
- Storage usage

## **🔔 Sistema de Alertas**

### **Alertas Automáticos**
```yaml
# Exemplo de regra de alerta
- alert: HighCPUUsage
  expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "High CPU usage on {{ $labels.instance }}"
    description: "CPU usage is above 80% for more than 5 minutes"
```

### **Alertas Configurados**
- ⚠️ **High CPU Usage** (>80% por 5min)
- ⚠️ **High Memory Usage** (>80% por 5min)
- 🚨 **Pod Restarting Frequently** (>5 em 15min)
- 🚨 **Node Down** (offline por 1min)

## **📈 Dashboards Disponíveis**

### **1. GKE Cluster Overview**
- CPU e Memory por pod
- Network I/O
- Pod status
- Resource quotas

### **2. GKE Node Metrics**
- CPU usage por nó
- Memory usage por nó
- Disk I/O
- Network metrics

### **3. Custom Dashboards**
- Aplicação específica
- Business metrics
- Performance KPIs
- Cost analysis

## **🚀 Como Acessar**

### **1. Grafana**
```bash
# URL: http://[IP_DO_LOAD_BALANCER]
Username: admin
Password: admin123
```

### **2. Prometheus**
```bash
# URL: http://[IP_DO_LOAD_BALANCER]:9090
# Query Language: PromQL
```

### **3. AlertManager**
```bash
# URL: http://[IP_DO_LOAD_BALANCER]:9093
# Gerenciar alertas e notificações
```

## **🔧 Configuração**

### **1. Instalação Automática**
```bash
# O Terraform instala automaticamente:
terraform apply
```

### **2. Configuração Manual (Opcional)**
```bash
# Acessar o cluster
gcloud container clusters get-credentials augustosredevops-cluster --region=us-west1

# Verificar pods
kubectl get pods -n monitoring

# Verificar serviços
kubectl get svc -n monitoring
```

## **📝 Exemplos de Queries PromQL**

### **CPU Usage por Pod**
```promql
sum(rate(container_cpu_usage_seconds_total{container!=""}[5m])) by (pod)
```

### **Memory Usage por Pod**
```promql
sum(rate(container_memory_usage_bytes{container!=""}[5m])) by (pod)
```

### **Pod Restarts**
```promql
increase(kube_pod_container_status_restarts_total[15m])
```

### **Node CPU**
```promql
100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

## **🎨 Customização de Dashboards**

### **1. Criar Novo Dashboard**
1. Acesse o Grafana
2. Clique em "+" → "Dashboard"
3. Adicione painéis com queries PromQL
4. Salve com nome descritivo

### **2. Importar Dashboard Existente**
1. Baixe JSON do dashboard
2. No Grafana: "+" → "Import"
3. Cole o JSON
4. Configure datasource (Prometheus)

### **3. Dashboard Templates**
- **Kubernetes Cluster**: ID 315
- **Node Exporter**: ID 1860
- **GKE Overview**: Custom (incluído)

## **🔒 Segurança**

### **1. Autenticação**
- Grafana: Username/Password
- Prometheus: Sem autenticação (interno)
- AlertManager: Sem autenticação (interno)

### **2. Network**
- LoadBalancer externo para acesso
- Pods rodam como usuário não-root
- Namespace isolado

### **3. Produção**
```bash
# Alterar senha padrão
kubectl patch secret prometheus-grafana -n monitoring \
  --type='json' -p='[{"op": "replace", "path": "/data/admin-password", "value":"[BASE64_NEW_PASSWORD]"}]'
```

## **💰 Custos**

### **Antes (Cloud Monitoring)**
- $0.25 por MB de métricas
- $0.50 por GB de logs
- $0.10 por alerta

### **Depois (Prometheus + Grafana)**
- **$0.00** para métricas
- **$0.00** para dashboards
- **$0.00** para alertas
- Apenas custo de storage GKE

## **📚 Recursos Adicionais**

### **1. Documentação Oficial**
- [Prometheus](https://prometheus.io/docs/)
- [Grafana](https://grafana.com/docs/)
- [Kube-Prometheus](https://github.com/prometheus-operator/kube-prometheus)

### **2. Dashboards Populares**
- [Grafana Dashboards](https://grafana.com/grafana/dashboards/)
- [Kubernetes Dashboards](https://grafana.com/grafana/dashboards/?search=kubernetes)

### **3. Comunidade**
- [Prometheus Users](https://groups.google.com/forum/#!forum/prometheus-users)
- [Grafana Community](https://community.grafana.com/)

## **🚨 Troubleshooting**

### **1. Prometheus não coleta métricas**
```bash
# Verificar targets
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
# Acesse: http://localhost:9090/targets
```

### **2. Grafana não carrega**
```bash
# Verificar logs
kubectl logs -n monitoring deployment/prometheus-grafana
```

### **3. Alertas não funcionam**
```bash
# Verificar AlertManager
kubectl logs -n monitoring deployment/prometheus-kube-prometheus-alertmanager
```

## **🎯 Próximos Passos**

### **1. Configurar Notificações**
- Email via SMTP
- Slack webhooks
- PagerDuty
- Teams

### **2. Adicionar Métricas Customizadas**
- Business KPIs
- Application metrics
- Cost tracking
- Performance baselines

### **3. Implementar SLOs/SLIs**
- Availability targets
- Performance thresholds
- Error budgets
- User experience metrics

---

## **✨ Resumo da Migração**

| Aspecto | Cloud Monitoring | Prometheus + Grafana |
|---------|------------------|---------------------|
| **Custo** | 💰💰💰 | 🆓 |
| **Flexibilidade** | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Dashboards** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Alertas** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Customização** | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Independência** | ⭐ | ⭐⭐⭐⭐⭐ |

**Resultado: Upgrade completo de monitoramento com economia de 100% nos custos! 🎉**
