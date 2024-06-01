variable "project" {
  description = "The GCP project ID"
  type        = string
  default     = "golden-totality-424813-q0"
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
  default     = "e2-medium"
}

variable "startup_script" {
  description = "The filename of the startup script"
  type        = string
  default     = "script.sh"
}


#sql deployemnt

variable "sql_instance_name" {
  description = "The name of the Cloud SQL instance"
  type        = string
  default     = "private-ip-sql-instance"
}

variable "sql_private_ip_name" {
  description = "The name of the private IP address for the Cloud SQL instance"
  type        = string
  default     = "private-ip-address"
}

variable "sql_database_version" {
  description = "The database version for the Cloud SQL instance"
  type        = string
  default     = "MYSQL_8_0"
}

variable "sql_tier" {
  description = "The machine type (tier) for the Cloud SQL instance"
  type        = string
  default     = "db-f1-micro"
}

variable "dns_domain_name" {
  description = "The name of the DNS domain for the private IPs of the peered network"
  type        = string
  default     = "example-com"
}

variable "dns_suffix" {
  description = "The DNS suffix for the private IPs of the peered network"
  type        = string
  default     = "example.com."
}
