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

output "node_pool_name" {
  description = "Nome do node pool"
  value       = google_container_node_pool.primary_nodes.name
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

output "backup_bucket" {
  description = "Nome do bucket de backup"
  value       = google_storage_bucket.backup_bucket.name
}

output "monitoring_dataset" {
  description = "Dataset do BigQuery para métricas"
  value       = google_bigquery_dataset.cluster_metrics.dataset_id
}

output "notification_topic" {
  description = "Tópico do Pub/Sub para notificações"
  value       = google_pubsub_topic.cluster_notifications.name
}
