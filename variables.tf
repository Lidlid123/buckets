# variables.tf

variable "project" {
  description = "The GCP project ID"
  type        = string
  default = "golden-totality-424813-q0"
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "me-west1"
}

variable "zone" {
  description = "The GCP zone"
  type        = string
  default     = "me-west1-a"
}

variable "network_name" {
  description = "The name of the VPC network"
  type        = string
  default     = "my-custom-mode-network"
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
  default     = "my-custom-subnet"
}

variable "subnet_cidr" {
  description = "The CIDR range for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_name" {
  description = "The name of the Compute Engine instance"
  type        = string
  default     = "flask-vm"
}

variable "machine_type" {
  description = "The machine type for the Compute Engine instance"
  type        = string
  default     = "f1-micro"
}

variable "startup_script" {
  description = "The filename of the startup script"
  type        = string
  default     = "script.sh"
}
