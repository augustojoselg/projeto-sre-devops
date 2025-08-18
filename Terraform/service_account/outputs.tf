output "devops_email" {
  description = "Email da conta de serviço DevOps criada"
  value       = google_service_account.devops.email
}

output "devops_private_key" {
  description = "Chave privada (codificada em Base64) da conta de serviço DevOps"
  value       = google_service_account_key.devops_key.private_key
  sensitive   = true
}

output "service_account_key_file" {
  value = local_file.devops_key_file.filename
}
