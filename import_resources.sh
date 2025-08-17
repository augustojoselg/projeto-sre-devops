#!/bin/bash

# Este script importa recursos existentes do GCP e Kubernetes para o estado do Terraform.
# Execute este script a partir do diretório 'Terraform/'.

# Navega para o diretório correto
cd Terraform || exit

# Inicializa o Terraform (necessário para o backend)
echo "==> Inicializando o Terraform..."
terraform init

# --- Importação de Recursos GCP ---

PROJECT_ID=$(gcloud config get-value project)
REGION="us-west1" # Certifique-se que esta é a região correta

echo "==> Importando recursos GCP para o projeto $PROJECT_ID..."

# Firewall
echo "--> Importando Firewall gke-master..."
terraform import google_compute_firewall.gke_master "projects/$PROJECT_ID/global/firewalls/gke-master-$PROJECT_ID"

echo "--> Importando Firewall gke-nodes..."
terraform import google_compute_firewall.gke_nodes "projects/$PROJECT_ID/global/firewalls/gke-nodes-$PROJECT_ID"

# Security Policy
echo "--> Importando Security Policy..."
terraform import google_compute_security_policy.security_policy "projects/$PROJECT_ID/global/securityPolicies/security-policy"

# SSL Certificate
echo "--> Importando Managed SSL Certificate..."
terraform import google_compute_managed_ssl_certificate.default "projects/$PROJECT_ID/global/sslCertificates/managed-ssl-certificate"

# Service Account
echo "--> Importando Service Account devops-sre..."
terraform import 'module.service_account.google_service_account.devops' "projects/$PROJECT_ID/serviceAccounts/devops-sre@$PROJECT_ID.iam.gserviceaccount.com"

# --- Importação de Recursos Kubernetes ---

echo "==> Importando recursos Kubernetes..."

# Namespaces
echo "--> Importando Namespace monitoring..."
terraform import kubernetes_namespace.monitoring monitoring

# Deployments
echo "--> Importando Deployment devops-whoami..."
terraform import kubernetes_deployment.devops_whoami devops/devops-whoami

echo "--> Importando Deployment sre-whoami..."
terraform import kubernetes_deployment.sre_whoami sre/sre-whoami

# --- Importação de Recursos do Cloud Build ---
# Nota: A importação de triggers do Cloud Build pode ser complexa devido ao ID.
# Vamos tentar com o nome, mas pode precisar de ajuste.
echo "--> Importando Cloud Build Trigger..."
terraform import google_cloudbuild_trigger.app_trigger "projects/$PROJECT_ID/locations/global/triggers/app-build-trigger" || echo "Falha ao importar Cloud Build Trigger. Pode ser necessário ajustar o ID ou importar manualmente."


echo "==> Processo de importação concluído!"
echo "==> Verifique o estado com 'terraform plan' para ver se há divergências."
