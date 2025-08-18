# 📋 Instalação do Cert-Manager via kubectl

## 🚀 Como instalar o cert-manager

### 1. Instalar o cert-manager
```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.3/cert-manager.yaml
```

### 2. Aguardar a instalação
```bash
kubectl get pods -n cert-manager
```

### 3. Criar o ClusterIssuer para Let's Encrypt
```bash
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: augustojoselg@gmail.com
    privateKeySecretRef:
      name: letsencrypt-prod-private-key
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
```

### 4. Verificar o status
```bash
kubectl get clusterissuer letsencrypt-prod
```

## ✅ Benefícios desta abordagem

- **Simplicidade**: Sem problemas de parsing no Terraform
- **Flexibilidade**: Fácil de atualizar e gerenciar
- **Estabilidade**: Método testado e confiável
- **Debugging**: Mais fácil de diagnosticar problemas

## 🔧 Configuração dos Ingress

Os ingress já estão configurados com as anotações corretas:
- `cert-manager.io/cluster-issuer: "letsencrypt-prod"`
- SSL redirect habilitado
- TLS configurado

## 📝 Notas importantes

1. **Execute primeiro**: `terraform apply` para criar a infraestrutura
2. **Depois instale**: cert-manager via kubectl
3. **Por último**: Os ingress serão criados com SSL automático

## 🎯 Resultado esperado

- **DevOps**: `https://devops.tisl.com.br` com SSL válido
- **SRE**: `https://sre.tisl.com.br` com SSL válido
- **Certificados**: Renovados automaticamente pelo cert-manager
