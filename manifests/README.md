# 🎯 Manifests Kubernetes

Esta pasta contém os manifests Kubernetes e scripts de instalação.

## 📁 Estrutura

- **`install-all.sh`** - Script de instalação completa
- **`install-ingress-nginx.sh`** - Instalação do Ingress Controller
- **`install-cert-manager.sh`** - Instalação do Cert-Manager
- **`install-monitoring.sh`** - Instalação do stack de monitoramento
- **`import_resources.sh`** - Script para importar recursos existentes

## 🚀 Como usar

### Instalação completa:
```bash
chmod +x install-all.sh
./install-all.sh
```

### Instalação individual:
```bash
chmod +x install-ingress-nginx.sh
./install-ingress-nginx.sh
```

## 📋 Pré-requisitos

- Cluster Kubernetes funcionando
- kubectl configurado
- Helm instalado (para alguns componentes)
- Permissões de administrador no cluster

## 🔧 Ordem de instalação recomendada

1. Ingress Controller
2. Cert-Manager
3. Monitoramento (Prometheus + Grafana)
4. Aplicações
