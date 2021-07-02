variable "cluster_name" {
  description = "Cluster name (prefix for all resource names)"
  default     = "hetzner"
}

variable "home_location" {
  description = "Hetzner location where resources resides, hel1 (Helsinki) or fsn1 (Falkenstein)"
  default     = "hel1"
}

variable "ip_count" {
  description = "Count of IPs in group"
  default     = 1
}

variable "ip_type" {
  description = "IP type (IPv4 or IPv6)"
  default     = "ipv4"
  validation {
    condition     = can(regex("^ipv[46]$", var.ip_type))
    error_message = "IP type is not valid."
  }
}
