# Regra de Firewall para permitir tráfego externo para o Ingress Controller.
# Esta regra permite que qualquer pessoa na internet (0.0.0.0/0) acesse
# as portas 80 (HTTP) e 443 (HTTPS) nos nós do cluster.
# O Ingress Controller escuta nessas portas para rotear o tráfego para os serviços corretos.
# A "target_tags" garante que esta regra se aplique apenas aos nós do GKE.
resource "google_compute_firewall" "allow_ingress" {
  name    = "${google_container_cluster.primary.name}-allow-ingress"
  network = google_compute_network.vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16", "35.191.0.0/16", "130.211.0.0/22"]
  target_tags   = google_container_cluster.primary.node_config[0].tags
}

# Regra de Firewall para permitir Health Checks do GCP Load Balancer.
# O Load Balancer do GKE usa health checks para verificar se os nós
# estão prontos para receber tráfego. Esta regra permite que os IPs
# dos health checkers do Google (faixas de IP específicas)
# alcancem os nós do cluster. As portas exatas são gerenciadas pelo GKE,
# então permitimos todas as portas TCP para essas fontes confiáveis.
resource "google_compute_firewall" "allow_health_checks" {
  name    = "${google_container_cluster.primary.name}-allow-health-checks"
  network = google_compute_network.vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  target_tags   = google_container_cluster.primary.node_config[0].tags
}
