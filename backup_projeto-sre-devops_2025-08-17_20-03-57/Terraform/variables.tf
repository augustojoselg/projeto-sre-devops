variable "project_id" {
  description = "ID do projeto GCP"
  type        = string
  default     = "augustosredevops"
}

variable "region" {
  description = "Região GCP"
  type        = string
  default     = "us-west1"
}

variable "zone" {
  description = "Zona GCP"
  type        = string
  default     = "us-west1-a"
}

variable "subnet_cidr" {
  description = "CIDR da subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "pods_cidr" {
  description = "CIDR para pods do cluster"
  type        = string
  default     = "10.1.0.0/16"
}

variable "services_cidr" {
  description = "CIDR para serviços do cluster"
  type        = string
  default     = "10.2.0.0/16"
}

variable "node_locations" {
  description = "Localizações dos nós para alta disponibilidade"
  type        = list(string)
  default     = ["us-west1-a", "us-west1-b"]
}

variable "node_count" {
  description = "Número inicial de nós"
  type        = number
  default     = 1
}

variable "min_node_count" {
  description = "Número mínimo de nós"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Número máximo de nós"
  type        = number
  default     = 2
}

variable "machine_type" {
  description = "Tipo de máquina para os nós"
  type        = string
  default     = "e2-standard-2"
}

variable "disk_size_gb" {
  description = "Tamanho do disco em GB"
  type        = number
  default     = 50
}

variable "allowed_ip_ranges" {
  description = "IPs permitidos para acesso"
  type        = list(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

variable "alert_email" {
  description = "Email para alertas"
  type        = string
  default     = "tisl@sysmac-nf.com.br"
}

variable "domain_name" {
  description = "Nome do domínio"
  type        = string
  default     = "devops.tisl.com.br"
}

variable "devops_domain" {
  description = "Domínio da aplicação DevOps"
  type        = string
  default     = "devops.tisl.com.br"
}

variable "sre_domain" {
  description = "Domínio da aplicação SRE"
  type        = string
  default     = "sre.tisl.com.br"
}

variable "github_owner" {
  description = "Proprietário do repositório GitHub"
  type        = string
  default     = "augustojoselg"
}

variable "github_repo" {
  description = "Nome do repositório GitHub"
  type        = string
  default     = "projeto-sre-devops"
}

variable "email_smtp_host" {
  description = "Host SMTP para envio de emails"
  type        = string
  default     = "mail.sysmac-nf.com.br"
}

variable "email_smtp_port" {
  description = "Porta SMTP para envio de emails"
  type        = string
  default     = "587"
}

variable "email_username" {
  description = "Usuário para autenticação SMTP"
  type        = string
  default     = "" # Configurar via variável de ambiente
}

variable "email_password" {
  description = "Senha para autenticação SMTP"
  type        = string
  default     = "" # Configurar via variável de ambiente
  sensitive   = true
}

variable "discord_webhook_url" {
  description = "URL do webhook do Discord para notificações"
  type        = string
  default     = ""
  sensitive   = true
}
