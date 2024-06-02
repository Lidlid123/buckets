# sql.tf

# Network for peering
resource "google_compute_network" "peering_network" {
  name                    = "private-network"
  auto_create_subnetworks = false
}

# Private IP address for SQL instance
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.peering_network.id
}

# Service networking connection
resource "google_service_networking_connection" "default" {
  network                 = google_compute_network.peering_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# SQL Database instance
resource "google_sql_database_instance" "instance" {
  name             = "private-ip-sql-instance"
  region           = "us-central1"
  database_version = "MYSQL_8_0"
  depends_on       = [google_service_networking_connection.default]
  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.peering_network.id
    }
  }
  deletion_protection = false
}

# Network peering routes configuration
resource "google_compute_network_peering_routes_config" "peering_routes" {
  peering              = google_service_networking_connection.default.peering
  network              = google_compute_network.peering_network.name
  import_custom_routes = true
  export_custom_routes = true
}

# Firewall rule to allow SQL access from VM
resource "google_compute_firewall" "allow_sql" {
  name = "allow-sql"
  allow {
    ports    = ["3306"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.peering_network.id
  priority      = 1000
  source_ranges = ["10.0.0.0/8"]
}
