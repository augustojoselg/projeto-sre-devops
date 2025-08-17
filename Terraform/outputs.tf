output "cluster_name" {
  description = "Nome do cluster GKE"
  value       = data.google_container_cluster.existing_cluster.name == "${var.project_id}-cluster" ? data.google_container_cluster.existing_cluster.name : google_container_cluster.primary[0].name
}

output "cluster_endpoint" {
  description = "Endpoint do cluster GKE"
  value       = data.google_container_cluster.existing_cluster.name == "${var.project_id}-cluster" ? data.google_container_cluster.existing_cluster.endpoint : google_container_cluster.primary[0].endpoint
}

output "cluster_location" {
  description = "Localização do cluster GKE"
  value       = data.google_container_cluster.existing_cluster.name == "${var.project_id}-cluster" ? data.google_container_cluster.existing_cluster.location : google_container_cluster.primary[0].location
}



output "vpc_name" {
  description = "Nome da VPC criada"
  value       = local.vpc_id
}

output "subnet_name" {
  description = "Nome da subnet"
  value       = data.google_compute_subnetwork.existing_subnet.name == "${var.project_id}-subnet" ? data.google_compute_subnetwork.existing_subnet.name : google_compute_subnetwork.subnet[0].name
}

output "load_balancer_ip" {
  description = "IP do load balancer (Ingress Controller)"
  value       = "A ser configurado pelo Ingress Controller"
}

output "domain_name" {
  description = "Nome do domínio configurado"
  value       = var.domain_name
}






