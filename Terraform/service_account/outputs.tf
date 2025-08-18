output "devops_email" {
  description = "Email da conta de serviço DevOps criada"
  value       = google_service_account.devops.email
}

