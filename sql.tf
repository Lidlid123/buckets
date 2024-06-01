


# Create a user with no password (not recommended for production)
resource "google_sql_user" "user" {
  name     = "app_user"
  instance = google_sql_database_instance.instance.name
  host     = "%"
  password = ""

  depends_on     = [google_service_networking_connection.default]
}

# Configure peering routes to import and export custom routes

# Optionally, configure DNS for the private IPs of the peered network
# resource "google_service_networking_peered_dns_domain" "default" {
#   name       = var.dns_domain_name
#   network    = google_compute_network.default.name
#   dns_suffix = var.dns_suffix
#   service    = "servicenetworking.googleapis.com"
# }
