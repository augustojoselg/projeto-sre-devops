output "service_account_email" {
  value = google_service_account.devops.email
}

output "service_account_key_file" {
  value = local_file.devops_key_file.filename
}
