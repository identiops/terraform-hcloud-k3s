variable "hcloud_token" {
  description = "Hetzner cloud auth token."
  type        = string
  sensitive   = true
}

# Cluster Settings
# ----------------

variable "delete_protection" {
  description = "Prevent cluster nodes from manual deletion. Is lifted automatically when cluster is destroyed. See https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server#delete_protection"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Cluster name (prefix for all resource names)."
  type        = string
  default     = "hetzner"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.cluster_name))
    error_message = "Cluster name must only contain characters allowed in DNS names (`^[a-z0-9-]+$`)."
  }
}

variable "location" {
  description = "Hetzner server location, see https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server#location."
  type        = string
  default     = "nbg1"
}

variable "k3s_channel" {
  description = "k3s channel (stable, latest, v1.19 and so on, see https://update.k3s.io/v1-release/channels)."
  type        = string
  default     = ""
}

variable "k3s_version" {
  description = "k3s version, if set, takes presdence over k3s_channel, see https://github.com/k3s-io/k3s/tags."
  type        = string
  default     = ""
}

variable "image" {
  description = "Node boot image."
  type        = string
  default     = "ubuntu-22.04"
}

variable "oidc_enabled" {
  description = "Configure OpenID Connect authentication for the cluster."
  type        = bool
  default     = false
}

variable "oidc_issuer_url" {
  description = "URL of the provider which allows the API server to discover public signing keys. Only URLs which use the https:// scheme are accepted. This is typically the provider's discovery URL without a path, for example \"https://accounts.google.com\" or \"https://login.salesforce.com\". This URL should point to the level below .well-known/openid-configuration."
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

# General Settings
# ----------------

variable "create_scripts" {
  description = "Create scripts to configure the kubectl context for the cluster."
  type        = bool
  default     = true
}

variable "network_cidr" {
  description = "CIDR of the private network."
  type        = string
  default     = "10.0.0.0/8"
}

variable "subnet_cidr" {
  description = "CIDR of the private network."
  type        = string
  default     = "10.0.1.0/24"
}

variable "cluster_cidr_network_offset" {
  description = "Cluster network offset."
  type        = number
  default     = 244 # WRRNING: CCM has this network preconfigured - don't change it without adjust CCM
}

variable "cluster_cidr_network_bits" {
  description = "Cluster network CIDR bits."
  type        = number
  default     = 16 # WRRNING: CCM has this network preconfigured - don't change it without adjust CCM
}

variable "service_cidr_network_offset" {
  description = "Service CIDR."
  type        = number
  default     = 43
}

variable "service_cidr_network_bits" {
  description = "Service network CIDR bits."
  type        = number
  default     = 16
}

variable "ip_offset" {
  description = "Offset from which agents are IPs are counted upwards. Needs to be adjusted to not cause collisions!"
  type        = number
  default     = 20
}

variable "enable_public_net_ipv4" {
  description = "Enable the assignment of a public IPv4 address (increases the costs per month)."
  type        = bool
  default     = false
}

variable "enable_public_net_ipv6" {
  description = "Enable the assignment of a public IPv6 address (increases the costs per month)."
  type        = bool
  default     = false
}

variable "ssh_keys" {
  description = "Map of public ssh keys."
  type        = map(string)
}

variable "hcloud_csi_driver_install" {
  description = "Install Hetzner CSI driver."
  type        = bool
  default     = true
}

variable "cilium_version" {
  description = "Cilium version, see https://github.com/cilium/cilium"
  type        = string
}

variable "kured_version" {
  description = "Kured version, see https://artifacthub.io/packages/helm/kured/kured"
  type        = string
}

variable "kured_reboot_days" {
  description = "Kured system reboot days, see https://kured.dev/docs/configuration/#setting-a-schedule"
  type        = string
  default     = "mo,tu,we,th,fr,sa,su"
}

variable "kured_start_time" {
  description = "Kured system reboot start time, see https://kured.dev/docs/configuration/#setting-a-schedule"
  type        = string
  default     = "2am"
}

variable "kured_end_time" {
  description = "Kured system reboot end time, see https://kured.dev/docs/configuration/#setting-a-schedule"
  type        = string
  default     = "5am"
}

variable "hcloud_csi_driver_version" {
  description = "Hetzner CSI driver version, see https://github.com/hetznercloud/csi-driver"
  type        = string
}

variable "hcloud_ccm_driver_install" {
  description = "Install Hetzner CCM."
  type        = bool
  default     = true
}

variable "hcloud_ccm_driver_version" {
  description = "Hetzner CCM version, see https://github.com/hetznercloud/hcloud-cloud-controller-manager"
  type        = string
}

variable "additional_packages" {
  description = "List of packages to install on all servers."
  type        = list(string)
  default     = []
}

variable "additional_runcmd" {
  description = "List of additional shell commands to append to the cloud-init runcmd section on all servers."
  type        = list(any)
  default     = []
}

variable "additional_cloud_init" {
  description = "Additional cloud-init configuration as a map that will be appended to user_data on all servers. You can use this to supply additional configuration or override existing keys."
  type = object({
    timezone = optional(string, "Europe/Berlin")
    locale   = optional(string, "en_US.UTF-8")
    users = optional(list(object({
      name          = string
      gecos         = string
      groups        = string
      lock_passwd   = bool
      shell         = string
      ssh_import_id = list(string)
      sudo          = list(string)
    })), [])
  })
}

variable "gateway_firewall_ids" {
  description = "A list of firewall IDs to apply on the gateway."
  type        = list(number)
  default     = []
}

variable "gateway_server_type" {
  description = "Gateway node type (size)."
  type        = string
  default     = "cx11"
  validation {
    condition     = can(regex("^(cp?x[1-5]1|cax[1-4]1|ccx[1-6]3)$", var.gateway_server_type))
    error_message = "Node type is not valid."
  }
}

variable "gateway_labels" {
  description = "Hetzner server labels for gateway."
  type        = map(string)
  default     = {}
}

# Control Plane Settings
# ----------------------

variable "control_plane_main_schedule_workloads" {
  description = "Schedule workloads on main control plane node"
  type        = bool
  default     = false
}

variable "control_plane_main_server_type" {
  description = "Main control plane node type (size)"
  type        = string
}

variable "control_plane_firewall_ids" {
  description = "A list of firewall IDs to apply on the control plane nodes."
  type        = list(number)
  default     = []
}

variable "control_plane_main_labels" {
  description = "Hetzner server labels for main control plane."
  type        = map(string)
  default     = {}
}

variable "control_plane_k3s_additional_options" {
  description = "Additional options passed to k3s control plane nodes during installation."
  type        = string
  default     = ""
}

# Node Pool Settings
# ------------------

variable "node_pools" {
  description = "Map of node pools, control plane and worker pools. Key is the node pool name, value an object specifying the server `type`, `count` of nodes, `labels`, `taints` (https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) and whether it's a control plane pool (`is_control_plane`) and workloads are `schedule_workloads`."
  type = map(object({
    is_control_plane   = optional(bool, false),
    schedule_workloads = optional(bool, true),
    type               = string,
    count              = number,
    labels             = map(string),
    taints             = map(string)
  }))
  default = {}
}

variable "worker_node_firewall_ids" {
  description = "A list of firewall IDs to apply on the work node servers."
  type        = list(number)
  default     = []
}
