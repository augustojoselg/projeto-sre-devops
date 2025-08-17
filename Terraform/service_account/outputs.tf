output "devops_email" {
  description = "E-mail da conta de serviço DevOps"
  value       = data.google_service_account.existing_devops_sa.email != "" ? data.google_service_account.existing_devops_sa.email : google_service_account.devops[0].email
}

output "devops_private_key" {
  description = "Chave privada da conta de serviço DevOps (codificada em Base64)"
  value       = google_service_account_key.devops_key.private_key
  sensitive   = true
}

output "service_account_key_file" {
  value = local_file.devops_key_file.filename
}
