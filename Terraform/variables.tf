variable "project_id" {
  description = "ID do projeto GCP"
  type        = string
  default     = "mythical-maxim-399820"
}

variable "region" {
  description = "Região GCP"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Zona GCP"
  type        = string
  default     = "us-central1-a"
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
  default     = ["us-central1-a", "us-central1-b", "us-central1-c"]
}

variable "node_count" {
  description = "Número inicial de nós"
  type        = number
  default     = 2
}

variable "min_node_count" {
  description = "Número mínimo de nós"
  type        = number
  default     = 2
}

variable "max_node_count" {
  description = "Número máximo de nós"
  type        = number
  default     = 5
}

variable "machine_type" {
  description = "Tipo de máquina para os nós"
  type        = string
  default     = "e2-standard-2"
}

variable "disk_size_gb" {
  description = "Tamanho do disco em GB"
  type        = number
  default     = 100
}

variable "allowed_ip_ranges" {
  description = "IPs permitidos para acesso"
  type        = list(string)
  default     = ["0.0.0.0/0"]
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

variable "github_owner" {
  description = "Proprietário do repositório GitHub"
  type        = string
  
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
  default     = "tisl@sysmac-nf.com.br" # Pegar a senha do email e remover daqui!
}

variable "email_password" {
  description = "Senha para autenticação SMTP"
  type        = string
  default     = "tisl@sysmac-nf.com.br" # Pegar a senha do email e remover daqui!
}

variable "discord_webhook_url" {
  description = "URL do webhook do Discord para notificações"
  type        = string
  default     = ""
}
