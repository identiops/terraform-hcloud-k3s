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

variable "master_type" {
  description = "Master node type (size)"
  default     = "cx21" # 2 vCPU, 4 GB RAM, 40 GB Disk space
  type        = string
}

variable "ssh_keys" {
  type        = list
  description = "List of public ssh_key ids"
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

variable "load_balancers" {
  description = "Load balancer services, target = server, agent or both"
  type        = map(object({ service = object(object({ destination_port = number, protocol = string })), target = string, type = string }))
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
