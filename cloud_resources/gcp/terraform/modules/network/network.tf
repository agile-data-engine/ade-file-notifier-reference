# VPC
resource "google_compute_network" "cloud_function_network" {
  name = "vpc-${var.app}-${var.env}"
  auto_create_subnetworks = false
}

# VPC connector
resource "google_vpc_access_connector" "connector" {
  name          = "vpcac-adenf-${var.env}" # GCP naming restrictions
  region        = var.region
  ip_cidr_range = var.cidr_range
  network       = google_compute_network.cloud_function_network.name
}

# IP address
resource "google_compute_address" "egress_ip_address" {
  name    = "ip-${var.app}-${var.env}"
  region  = var.region
}

# Router
resource "google_compute_router" "router" {
  name    = "gcr-${var.app}-${var.env}"
  region  = var.region
  network = google_compute_network.cloud_function_network.name
}

# NAT
resource "google_compute_router_nat" "cloud_function_nat" {
  name  = "nat-${var.app}-${var.env}"
  router = google_compute_router.router.name
  region = google_compute_router.router.region
  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips = google_compute_address.egress_ip_address.*.self_link

  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}