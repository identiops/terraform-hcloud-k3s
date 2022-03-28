variable "cluster_name" {
  description = "Cluster name (prefix for all resource names)"
  default     = "hetzner"
}

variable "datacenter" {
  description = "Hetzner datacenter where resources reside: hel1-dc2 (Helsinki 1 DC 2), nbg1-dc3 (Nürnberg 1 DC 3), or fsn1-dc14 (Falkenstein 1 DC 14)"
  default     = "hel1-dc2"
}

variable "node_count" {
  description = "Count on nodes in group"
  default     = 1
}

variable "node_type" {
  description = "Node type (size)"
  default     = "cx21" # 2 vCPU, 4 GB RAM, 40 GB Disk space
  validation {
    condition     = can(regex("^cx11$|^cpx11$|^cx21$|^cpx21$|^cx31$|^cpx31$|^cx41$|^cpx41$|^cx51$|^cpx51$|^ccx11$|^ccx21$|^ccx31$|^ccx41$|^ccx51$", var.node_type))
    error_message = "Node type is not valid."
  }
}

variable "image" {
  description = "Node boot image"
  default     = "ubuntu-20.04"
}

variable "k3s_token" {
  description = "k3s initialization token"
}

variable "k3s_version" {
  description = "k3s version, if set, takes presedence over k3s_channel"
  default     = ""
}

variable "k3s_channel" {
  description = "k3s channel (stable, latest, v1.19 and so on)"
  default     = "stable"
}

variable "control_plane_master_internal_ipv4" {
  description = "Internal IP address (v4) of master node"
}

variable "floating_ips" {
  description = "Floating IP addresses"
}

variable "ssh_keys" {
  description = "Public SSH keys ids (list) used to login"
}

variable "hcloud_network_id" {
  description = "IP Network id"
}

variable "hcloud_subnet_id" {
  description = "IP Subnet id used to assign internal IP addresses to nodes"
}

variable "subnet_ip_range" {
  description = "CIDR block of the subnet"
}

variable "ip_offset" {
  description = "Offset from which agents are IPs are counted upwards. Needs to be adjusted to not cause collisions!"
}


variable "additional_user_data" {
  description = "Additional user_data that gets executed on the host"
}

variable "firewall_ids" {
  description = "A list of firewall IDs to apply on the node_group"
  type        = list(number)
  default     = []
}

variable "apt_packages" {
  description = "List of packages to install using apt."
  type        = list(string)
  default     = []
}

variable "additional_yaml" {
  description = "Additional sections to append to the cloud-init file."
  type = string
  default = ""
}
