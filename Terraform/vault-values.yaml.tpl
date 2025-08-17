# Configuração para o chart Helm do HashiCorp Vault
# MODO DE PRODUÇÃO - HA com Backend GCS e Auto-Unseal KMS

# Configurações globais
global:
  # Habilita o TLS, essencial para produção
  tlsDisable: false

# Configurações do servidor Vault
server:
  # Desabilita o modo de desenvolvimento
  dev:
    enabled: false

  # Habilita o modo de Alta Disponibilidade (HA)
  ha:
    enabled: true
    replicas: 3
    # Configuração do backend GCS
    config: |
      ui = true
      
      storage "gcs" {
        bucket     = "${vault_storage_bucket}"
        ha_enabled = "true"
      }

      seal "gcpckms" {
        project    = "${gcp_project_id}"
        region     = "${gcp_region}"
        key_ring   = "${kms_key_ring}"
        crypto_key = "${kms_crypto_key}"
      }

      listener "tcp" {
        address     = "0.0.0.0:8200"
        cluster_address = "0.0.0.0:8201"
        tls_disable = "false" # Usar o TLS gerenciado pelo Helm
        tls_cert_file = "/vault/userconfig/vault-server-tls/vault.crt"
        tls_key_file  = "/vault/userconfig/vault-server-tls/vault.key"
      }

  # Anotações para vincular a KSA à GSA via Workload Identity
  serviceAccount:
    annotations:
      iam.gke.io/gcp-service-account: "${vault_gcp_sa_email}"

# Habilita a UI do Vault
ui:
  enabled: true
  serviceType: "LoadBalancer"
