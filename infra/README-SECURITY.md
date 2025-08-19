# 🔐 Configuração de Segurança - Variáveis Sensíveis

## **Variáveis que precisam ser configuradas via GitHub Secrets**

### **1. Senhas de Aplicação**

#### **GRAFANA_PASSWORD**
- **Descrição**: Senha para acesso ao Grafana
- **Tipo**: String
- **Recomendação**: Senha forte com pelo menos 16 caracteres
- **Exemplo**: `MySecureGrafanaPass123!`

#### **INFLUXDB_PASSWORD**
- **Descrição**: Senha para acesso ao InfluxDB
- **Tipo**: String
- **Recomendação**: Senha forte com pelo menos 16 caracteres
- **Exemplo**: `MySecureInfluxDBPass456!`

### **2. Como Configurar no GitHub**

1. **Acesse seu repositório** no GitHub
2. **Vá para Settings > Secrets and variables > Actions**
3. **Clique em "New repository secret"**
4. **Adicione cada variável** com seu respectivo valor

### **3. Estrutura dos Secrets**

```yaml
# Secrets existentes (já configurados)
GOOGLE_PROJECT_ID: "seu-projeto-id"
GOOGLE_REGION: "us-west1"
GOOGLE_CLUSTER_NAME: "seu-cluster-name"
GOOGLE_CLUSTER_ZONE: "us-west1-a"
WORKLOAD_IDENTITY_PROVIDER: "projects/.../workloadIdentityPools/..."
SERVICE_ACCOUNT_EMAIL: "devops-sre@...iam.gserviceaccount.com"

# Novos secrets para adicionar
GRAFANA_PASSWORD: "sua-senha-grafana"
INFLUXDB_PASSWORD: "sua-senha-influxdb"
```

### **4. Validação**

Após configurar os secrets, o pipeline do GitHub Actions irá:
1. **Passar as variáveis** para o Terraform
2. **Validar** que todas as variáveis estão definidas
3. **Aplicar** a configuração com as senhas seguras

### **5. Segurança**

- ✅ **Senhas nunca são expostas** no código
- ✅ **Variáveis marcadas como `sensitive`** no Terraform
- ✅ **Secrets criptografados** no GitHub
- ✅ **Acesso restrito** apenas aos colaboradores autorizados

### **6. Rotação de Senhas**

Para alterar as senhas:
1. **Atualize o secret** no GitHub
2. **Execute o pipeline** novamente
3. **Terraform aplicará** as novas senhas automaticamente

---

**⚠️ IMPORTANTE**: Nunca commite senhas diretamente no código. Sempre use secrets do GitHub ou variáveis de ambiente.
