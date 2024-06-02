provider "google" {
  project = "golden-totality-424813-q0"
  region  = "me-west1"
}

resource "google_compute_instance" "custom_hostname_instance" {
  name         = "jenkins-deployed-terraform"
  machine_type = "e2-medium"
  zone         = "me-west1"

  # Set a custom hostname below
  hostname = "kikosolutions.com"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }
}