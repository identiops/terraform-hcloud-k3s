variable "hcloud_token" {
  description = "Hetzner cloud auth token"
}

variable "cluster_name" {
  description = "Cluster name (prefix for all resource names)"
  default     = "hetzner"
}

variable "datacenter" {
  description = "Hetzner datacenter where resources reside: hel1-dc2 (Helsinki 1 DC 2), nbg1-dc3 (Nürnberg 1 DC 3), or fsn1-dc14 (Falkenstein 1 DC 14)"
  default     = "hel1-dc2"
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
  description = "k3s channel (stable, latest, v1.19 and so on, see https://update.k3s.io/v1-release/channels)"
  default     = "stable"
}

variable "ssh_keys" {
  description = "Public SSH keys ids (list) used to login"
}

variable "hcloud_subnet_id" {
  description = "IP Subnet id used to assign internal IP addresses to nodes"
}

variable "cluster_cidr_network" {
  description = "Cluster network"
  type        = string
}

variable "service_cidr_network" {
  description = "Service network"
  type        = string
}

variable "hcloud_network_ip" {
  description = "Herzner cloud private network ip address"
}

variable "hcloud_network_id" {
  description = "Herzner cloud private network Id"
}

variable "additional_user_data" {
  description = "Additional user_data that gets executed on the host"
}

variable "firewall_ids" {
  description = "A list of firewall rules to apply"
  type        = list(number)
  default     = []
}

variable "hcloud_csi_driver_version" {
  description = "Hetzner CSI driver version, see https://github.com/hetznercloud/csi-driver"
  type        = string
}

variable "hcloud_ccm_driver_version" {
  description = "Hetzner CCM version, see https://github.com/hetznercloud/hcloud-cloud-controller-manager"
  type        = string
}
