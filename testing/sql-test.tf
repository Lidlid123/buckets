# Reference the existing VPC
data "google_compute_network" "existing_vpc" {
  name = "default"
}

# [START vpc_mysql_instance_private_ip_address]
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = data.google_compute_network.existing_vpc.id
}
# [END vpc_mysql_instance_private_ip_address]

# [START vpc_mysql_instance_private_ip_service_connection]
resource "google_service_networking_connection" "default" {
  network                 = data.google_compute_network.existing_vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}
# [END vpc_mysql_instance_private_ip_service_connection]

# [START cloud_sql_mysql_instance_private_ip_instance]
resource "google_sql_database_instance" "instance" {
  name             = "private-ip-sql-instance"
  region           = "me-west1"
  database_version = "MYSQL_8_0"

  depends_on = [google_service_networking_connection.default]

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = "false"
      private_network = data.google_compute_network.existing_vpc.self_link
    }
  }
  deletion_protection = false
}
# [END cloud_sql_mysql_instance_private_ip_instance]

# [START cloud_sql_mysql_instance_private_ip_routes]
resource "google_compute_network_peering_routes_config" "peering_routes" {
  peering              = google_service_networking_connection.default.peering
  network              = data.google_compute_network.existing_vpc.name
  import_custom_routes = true
  export_custom_routes = true


}
# [END cloud_sql_mysql_instance_private_ip_routes]
