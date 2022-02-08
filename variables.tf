variable "hcloud_token" {
  description = "Hetzner cloud auth token"
  type        = string
}

variable "cluster_name" {
  description = "Cluster name (prefix for all resource names)"
  default     = "hetzner"
  type        = string
}

variable "datacenter" {
  description = "Hetzner datacenter where resources reside: hel1-dc2 (Helsinki 1 DC 2), nbg1-dc3 (Nürnberg 1 DC 3), or fsn1-dc14 (Falkenstein 1 DC 14)"
  default     = "hel1-dc2"
  type        = string
}

variable "image" {
  description = "Node boot image"
  default     = "ubuntu-20.04"
  type        = string
}

variable "network_cidr" {
  description = "CIDR of the private network"
  default     = "10.0.0.0/8"
}

variable "subnet_cidr" {
  description = "CIDR of the private network"
  default     = "10.0.0.0/24"
}

variable "master_type" {
  description = "Master node type (size)"
  default     = "cx21" # 2 vCPU, 4 GB RAM, 40 GB Disk space
  type        = string
}

variable "ssh_keys" {
  type        = list(any)
  description = "List of public ssh_key ids"
}

variable "k3s_version" {
  description = "k3s version, if set, takes presedence over k3s_channel"
  default     = ""
  type        = string
}

variable "k3s_channel" {
  default = "stable"
  type    = string
}

variable "node_groups" {
  description = "Map of worker node groups, key is server_type, value is count of nodes in group"
  type        = map(string)
  default = {
    "cx21" = 1
  }
}

variable "floating_ips" {
  description = "Map of floating IPs, key is ip_type (ipv4, ipv6), value is count of IPs in group"
  type        = map(string)
  default     = {}
}

variable "master_user_data" {
  description = "Additional user_data that gets executed on the master in bash format"
  default     = ""
}

variable "node_user_data" {
  description = "Additional user_data that gets executed on the nodes in bash format"
  default     = ""
}

variable "master_firewall_ids" {
  description = "A list of firewall IDs to apply on the master"
  type        = list(number)
  default     = []
}

variable "node_group_firewall_ids" {
  description = "A list of firewall IDs to apply on the node group servers"
  type        = list(number)
  default     = []
}
