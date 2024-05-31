# main.tf

# Configure the Google Cloud provider


# Create a VPC network
resource "google_compute_network" "vpc_network" {
  name                    = var.network_name
  auto_create_subnetworks = false
  mtu                     = 1460
}

# Create a subnet within the VPC network
resource "google_compute_subnetwork" "default" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

#firewall rules
resource "google_compute_firewall" "ssh" {
  name = "allow-ssh"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}


resource "google_compute_firewall" "flask" {
  name = "allow-flask"
  allow {
    ports    = ["5000"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}


# Read the startup script content
data "local_file" "startup_script" {
  filename = var.startup_script
}

# Create a single Compute Engine instance
resource "google_compute_instance" "default" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  metadata = {
    startup-script = data.local_file.startup_script.content
  }

  network_interface {
    subnetwork = google_compute_subnetwork.default.id

    access_config {
      # Uncomment and configure if needed
    }
  }
}
