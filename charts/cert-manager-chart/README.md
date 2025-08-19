# 🔐 Chart Helm do Cert-Manager

Este chart Helm personalizado instala e configura o **cert-manager** de forma robusta e controlada.

## **🚀 Funcionalidades**

- ✅ **Instalação automática** do cert-manager via Helm
- ✅ **Configuração automática** do ClusterIssuer para Let's Encrypt
- ✅ **Verificação de readiness** com job de validação
- ✅ **Timeouts configuráveis** para instalação robusta
- ✅ **Integração com NGINX Ingress** Controller

## **📁 Estrutura do Chart**

```
cert-manager-chart/
├── Chart.yaml              # Metadados do chart
├── values.yaml             # Valores padrão
├── templates/
│   ├── namespace.yaml      # Namespace do cert-manager
│   ├── cert-manager.yaml   # Instalação via Helm dependency
│   ├── cluster-issuer.yaml # ClusterIssuer para Let's Encrypt
│   └── readiness-check.yaml # Job de verificação de readiness
└── README.md               # Esta documentação
```

## **⚙️ Configuração**

### **Valores Principais:**

```yaml
# Configurações do cert-manager
certManager:
  version: "v1.13.3"
  installCRDs: true
  timeout: 900

# Configurações do ClusterIssuer
clusterIssuer:
  enabled: true
  name: "letsencrypt-prod"
  email: "seu-email@exemplo.com"
  server: "https://acme-v02.api.letsencrypt.org/directory"

# Configurações de namespace
namespace:
  name: "cert-manager"
  create: true
```

## **🔧 Uso com Terraform**

```hcl
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  chart            = "${path.module}/../Helm/cert-manager-chart"
  namespace        = "cert-manager"
  create_namespace = true
  
  wait    = true
  timeout = 1200
  
  set {
    name  = "clusterIssuer.email"
    value = var.cert_manager_email
  }
}
```

## **📋 Fluxo de Instalação**

1. **Criação do namespace** (se habilitado)
2. **Instalação do cert-manager** via Helm dependency
3. **Criação do ClusterIssuer** para Let's Encrypt
4. **Job de verificação** de readiness
5. **Validação** dos CRDs e pods

## **🔄 Atualizações**

Para atualizar o cert-manager:

1. **Modifique a versão** em `values.yaml`
2. **Atualize o Terraform** se necessário
3. **Aplique as mudanças** via pipeline

## **🚨 Troubleshooting**

### **Problema: CRDs não instalados**
- Verifique se `installCRDs: true`
- Aumente o timeout se necessário

### **Problema: ClusterIssuer não criado**
- Verifique se `clusterIssuer.enabled: true`
- Confirme se o email está correto

### **Problema: Timeout na instalação**
- Aumente o valor de `timeout` no Terraform
- Verifique a conectividade do cluster

## **🔗 Referências**

- [Cert-Manager Documentation](https://cert-manager.io/docs/)
- [Let's Encrypt](https://letsencrypt.org/)
- [Helm Charts](https://helm.sh/docs/)
