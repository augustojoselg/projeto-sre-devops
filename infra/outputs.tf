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
  description = "IP estático do Load Balancer"
  value       = google_compute_global_address.load_balancer_ip.address
}






