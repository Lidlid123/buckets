resource "google_sql_database_instance" "instance" {
  name             = var.sql_instance_name
  region           = var.region
  database_version = var.sql_database_version

  settings {
    tier = var.sql_tier
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.default.id
    }
  }

  deletion_protection = false

  # Ensure SQL instance is destroyed before the networking connection
   depends_on = [google_service_networking_connection.default]
}

resource "google_sql_user" "user" {
  name     = "app_user"
  instance = google_sql_database_instance.instance.name
  host     = "%"
  password = ""

  
}
