# main.tf

# Create the main network
resource "google_compute_network" "default" {
  name                    = var.network_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# Create a subnetwork for the VM
resource "google_compute_subnetwork" "default" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_cidr
  network       = google_compute_network.default.id
  region        = var.region
}

# Create a proxy-only subnetwork
resource "google_compute_subnetwork" "proxy_only" {
  name          = "proxy-only-subnet"
  ip_cidr_range = "10.129.0.0/23"
  network       = google_compute_network.default.id
  region        = var.region
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}

# Firewall rule for health checks
resource "google_compute_firewall" "default" {
  name = "fw-allow-health-check"
  allow {
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.default.id
  priority      = 1000
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["load-balanced-backend"]
}

# Firewall rule to allow traffic from the proxy subnet
resource "google_compute_firewall" "allow_proxy" {
  name = "fw-allow-proxies"
  allow {
    ports    = ["443", "80", "8080", "5000"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.default.id
  priority      = 1000
  source_ranges = ["10.129.0.0/23"]
  target_tags   = ["load-balanced-backend"]
}

# VM instance template
resource "google_compute_instance_template" "default" {
  name = var.instance_name
  disk {
    auto_delete  = true
    boot         = true
    source_image = "projects/debian-cloud/global/images/family/debian-10"
  }
  machine_type = var.machine_type
  metadata = {
    startup-script = file(var.startup_script)
  }
  network_interface {
    network    = google_compute_network.default.id
    subnetwork = google_compute_subnetwork.default.id
    access_config {
      network_tier = "PREMIUM"
    }
  }
  service_account {
    email  = "default"
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/pubsub",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append"
    ]
  }
  tags = ["load-balanced-backend"]
}

# Instance group manager for VM instances
resource "google_compute_instance_group_manager" "default" {
  name               = var.instance_name
  base_instance_name = var.instance_name
  target_size        = 2
  version {
    instance_template = google_compute_instance_template.default.id
  }
  named_port {
    name = "http"
    port = 5000
  }
  zone = var.zone
}

# External IP address for load balancer
resource "google_compute_address" "default" {
  name         = var.instance_name
  address_type = "EXTERNAL"
  region       = var.region
}

# Health check for the instances
resource "google_compute_region_health_check" "default" {
  name               = var.instance_name
  check_interval_sec = 5
  healthy_threshold  = 2
  http_health_check {
    port         = 5000
    request_path = "/"
  }
  region              = var.region
  timeout_sec         = 5
  unhealthy_threshold = 2
}

# Backend service for load balancing
resource "google_compute_region_backend_service" "default" {
  name                  = var.instance_name
  region                = var.region
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_region_health_check.default.id]
  protocol              = "HTTP"
  timeout_sec           = 30
  backend {
    group           = google_compute_instance_group_manager.default.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

# URL map for routing traffic
resource "google_compute_region_url_map" "default" {
  name            = var.instance_name
  region          = var.region
  default_service = google_compute_region_backend_service.default.id
}

# Target HTTP proxy for load balancer
resource "google_compute_region_target_http_proxy" "default" {
  name    = var.instance_name
  region  = var.region
  url_map = google_compute_region_url_map.default.id
}

# Forwarding rule for load balancer
resource "google_compute_forwarding_rule" "default" {
  name       = var.instance_name
  provider   = google-beta
  region     = var.region
  project    = var.project
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_region_target_http_proxy.default.id
  network               = google_compute_network.default.id
  ip_address            = google_compute_address.default.id
  depends_on            = [
    google_compute_subnetwork.proxy_only,
    google_compute_region_target_http_proxy.default,
  ]
}
