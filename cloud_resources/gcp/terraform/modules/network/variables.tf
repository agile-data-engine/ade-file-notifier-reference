variable "app" {
  type = string
  description = "Application name to be used for resource naming"
}

variable "env" {
  type = string
  description = "Environment name"
}

variable "region" {
  type = string
  description = "Region for resources"
}

variable "cidr_range" {
  type = string
  description = "Network CIDR range to be used for the notifier network."
}

variable "nat_ip_allocate_option" {
  type = string
  description = "How external IPs should be allocated for this NAT."
}

variable "source_subnetwork_ip_ranges_to_nat" {
  type = string
  description = "How NAT should be configured per Subnetwork."
}

variable "max_instances" {
  type = string
  description = "Max instances for the VPC Access Controller."
}

variable "min_instances" {
  type = string
  description = "Min instances for the VPC Access Controller."
}