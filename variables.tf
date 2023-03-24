variable "hcloud_token" {
  description = "Hetzner cloud auth token"
  type        = string
}

variable "cluster_name" {
  description = "Cluster name (prefix for all resource names)"
  type        = string
  default     = "hetzner"
}

variable "datacenter" {
  description = "Hetzner datacenter where resources reside: hel1-dc2 (Helsinki 1 DC 2), nbg1-dc3 (Nürnberg 1 DC 3), or fsn1-dc14 (Falkenstein 1 DC 14)"
  type        = string
  default     = "hel1-dc2"
}

variable "image" {
  description = "Node boot image"
  type        = string
  default     = "ubuntu-22.04"
}

variable "network_cidr" {
  description = "CIDR of the private network"
  type        = string
  default     = "10.0.0.0/8"
}

variable "subnet_cidr" {
  description = "CIDR of the private network"
  type        = string
  default     = "10.0.1.0/24"
}

variable "cluster_cidr_network_offset" {
  description = "Cluster network offset"
  type        = number
  default     = 244 # CCM has this network preconfigured - don't change it without adjust CCM
}

variable "cluster_cidr_network_bits" {
  description = "Cluster network CIDR bits"
  type        = number
  default     = 16 # CCM has this network preconfigured - don't change it without adjust CCM
}

variable "service_cidr_network_offset" {
  description = "Service CIDR"
  type        = number
  default     = 43
}

variable "service_cidr_network_bits" {
  description = "Service network CIDR bits"
  type        = number
  default     = 16
}

variable "ip_offset" {
  description = "Offset from which agents are IPs are counted upwards. Needs to be adjusted to not cause collisions!"
  default     = 20
}

variable "control_plane_k3s_additional_options" {
  description = "Additional options passed to k3s during installation"
  type        = string
  default     = "--node-taint node-role.kubernetes.io/master:NoSchedule"
}

variable "control_plane_server_type" {
  description = "Control plane node type (size)"
  type        = string
  default     = "cx21" # 2 vCPU, 4 GB RAM, 40 GB Disk space
}

variable "control_plane_server_count" {
  description = "Number of control plane nodes"
  type        = number
  default     = 3
}

variable "ssh_keys" {
  description = "List of public ssh_key ids"
  type        = list(any)
}

variable "k3s_version" {
  description = "k3s version, if set, takes presedence over k3s_channel"
  type        = string
  default     = ""
}

variable "k3s_channel" {
  description = "k3s release channel"
  type        = string
  default     = "stable"
}

variable "node_groups" {
  description = "Map of worker node groups, key is server_type, value is count of nodes in group"
  type        = map(string)
  default     = { "cx21" = 1 }
}

variable "nodes" {
  description = "Map of worker node groups, key is node_id, value is the server type"
  type = map(object({
    server_type = string
    ip_index    = number
  }))
  default = {
    "name" = {
      server_type = "cx21"
      ip_index    = 0
    }
  }
}

variable "control_plane_firewall_ids" {
  description = "A list of firewall IDs to apply on the master"
  type        = list(number)
  default     = []
}

variable "node_group_firewall_ids" {
  description = "A list of firewall IDs to apply on the node group servers"
  default     = []
  type        = list(number)
}

variable "node_firewall_ids" {
  description = "A list of firewall IDs to apply on the node servers"
  default     = []
  type        = list(number)
}

variable "hcloud_csi_driver_install" {
  description = "Install Hetzner CSI driver"
  type        = bool
  default     = true
}

variable "hcloud_csi_driver_version" {
  description = "Hetzner CSI driver version, see https://github.com/hetznercloud/csi-driver"
  type        = string
  default     = "v1.6.0"
}

variable "hcloud_ccm_driver_install" {
  description = "Install Hetzner CCM"
  type        = bool
  default     = true
}

variable "hcloud_ccm_driver_version" {
  description = "Hetzner CCM version, see https://github.com/hetznercloud/hcloud-cloud-controller-manager"
  type        = string
  default     = "v1.12.1"
}

variable "allow_server_deletion" {
  description = "Allow server deletion"
  type        = bool
  default     = false
}

variable "oidc_enabled" {
  description = "Configure OpenID Connect authentication for the cluster."
  type        = bool
  default     = false
}

variable "oidc_issuer_url" {
  description = "URL of the provider which allows the API server to discover public signing keys. Only URLs which use the https:// scheme are accepted. This is typically the provider's discovery URL without a path, for example \"https://accounts.google.com\" or \"https://login.salesforce.com\". This URL should point to the level below .well-known/openid-configuration"
  type        = string
  default     = ""
}

variable "oidc_client_id" {
  description = "The OpenID Connect client id, a public identifier of this application/cluster."
  type        = string
  default     = ""
}

variable "oidc_client_secret" {
  description = "The OpenID Connect client secret of this application/cluster."
  sensitive   = true
  type        = string
  default     = ""
}

variable "control_plane_labels" {
  description = "Hetzner server labels for control plane."
  type        = map(string)
}

variable "node_labels" {
  description = "Hetzner server labels for worker nodes."
  type        = map(string)
}

variable "server_additional_packages" {
  description = "List of packages to install on the servers."
  type        = list(string)
  default     = []
}

variable "additional_cloud_init" {
  description = "Additional cloud-init configuration as a map that will be appended to user_data on all servers. You can use this to supply additional configuration or override existing keys."
  type = object({
    timezone = string
    locale   = string
    users = list(object({
      name          = string
      gecos         = string
      groups        = string
      lock_passwd   = bool
      shell         = string
      ssh_import_id = list(string)
      sudo          = list(string)
    }))
  })
  default = {
    timezone = ""
    locale   = ""
    users    = []
  }
}

variable "additional_runcmd" {
  description = "List of additional shell commands to append to the cloud-init runcmd section."
  type        = list(any)
  default     = []
}

variable "create_scripts" {
  description = "Create scripts to configure the kubectl context for the cluster."
  type        = bool
  default     = true
}
