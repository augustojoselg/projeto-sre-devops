# 📦 Charts Helm

Esta pasta contém os charts Helm customizados para o projeto SRE DevOps.

## 📁 Estrutura

- **`app-chart/`** - Chart genérico para aplicações
- **`cert-manager-chart/`** - Chart para instalação do cert-manager
- **`devops-values.yaml`** - Valores para ambiente DevOps
- **`sre-values.yaml`** - Valores para ambiente SRE

## 🚀 Como usar

### Instalar uma aplicação:
```bash
helm install devops-app ./app-chart -f devops-values.yaml
```

### Instalar cert-manager:
```bash
helm install cert-manager ./cert-manager-chart
```

## 📋 Dependências

- Kubernetes 1.19+
- Helm 3.0+
- cert-manager (para charts que usam certificados)
