output "cluster_name" {
  description = "Nome do cluster GKE"
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "Endpoint do cluster GKE"
  value       = google_container_cluster.primary.endpoint
}

output "cluster_location" {
  description = "Localização do cluster GKE"
  value       = google_container_cluster.primary.location
}



output "vpc_name" {
  description = "Nome da VPC"
  value       = google_compute_network.vpc.name
}

output "subnet_name" {
  description = "Nome da subnet"
  value       = google_compute_subnetwork.subnet.name
}

output "load_balancer_ip" {
  description = "IP do load balancer"
  value       = google_compute_global_forwarding_rule.default.ip_address
}

output "domain_name" {
  description = "Nome do domínio configurado"
  value       = var.domain_name
}






