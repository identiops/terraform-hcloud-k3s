# Terraform language documentation: https://www.terraform.io/docs/language/index.html
# HCL language specification: https://github.com/hashicorp/hcl/blob/main/hclsyntax/spec.md

###########################
#  Backend and Providers  #
###########################

terraform {
  # Configure custom storage backend
  backend "local" {
    path = "terraform.tfstate"
  }
  required_version = ">= 1.0"
}

###########################
#  Cluster configuration  #
###########################

module "cluster" {
  source       = "github.com/identiops/terraform-hcloud-k3s"
  hcloud_token = var.hcloud_token # INFO: Set via `export TF_VAR_hcloud_token=xyz

  # Cluster Settings
  # ----------------
  delete_protection = true # Must be set to false + `terraform apply` before destroying the cluster via `terraform destory`!
  cluster_name      = "production"
  location          = "nbg1"         # See available locations https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server#location
  k3s_version       = "v1.28.5+k3s1" # See available versions https://github.com/k3s-io/k3s/tags.

  # General Settings
  # ----------------
  ssh_keys = {
    "john" = file("john.pub")
    "jane" = "ssh-xxxx xxxxx jane@example"
  }
  cilium_version                  = "1.14.5" # See available version https://github.com/cilium/cilium
  hcloud_ccm_driver_chart_version = "1.19.0" # Check k8s compatibility https://github.com/hetznercloud/hcloud-cloud-controller-manager#versioning-policy
  hcloud_csi_driver_chart_version = "2.6.0"  # Check k8s compatibility https://github.com/hetznercloud/csi-driver/blob/main/docs/kubernetes/README.md#versioning-policy
  kured_chart_version             = "5.4.1"  # See available version https://artifacthub.io/packages/helm/kured/kured

  # Control Plane Settings
  # ----------------------
  control_plane_main_schedule_workloads = true
  control_plane_main_server_type        = "cx31" # See available types https://docs.hetzner.com/cloud/servers/overview#shared-vcpu
  additional_cloud_init = {
    timezone = "Europe/Berlin" # See available time zones https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List
  }

  # Node Group Settings
  # -------------------
  # Map of worker node groups, key is server_type, value is count of nodes in group
  node_pools = {
    system = {
      is_control_plane   = true
      schedule_workloads = true
      type               = "cx31" # See available types https://docs.hetzner.com/cloud/servers/overview#shared-vcpu
      count              = 2
      labels = {
        # "control-plane" = "yes"
      }
      taints = {
        # "MyTaint=true" = "NoSchedule"
      }
    }
    workers = {
      is_control_plane   = false
      schedule_workloads = true
      type               = "cx31" # See available types https://docs.hetzner.com/cloud/servers/overview#shared-vcpu
      count              = 3
      labels             = {}
      taints             = {}
    }
  }
}


###############
#  Variables  #
###############

variable "hcloud_token" {
  description = "Hetzner cloud auth token."
  type        = string
  sensitive   = true
}

############
#  Output  #
############

output "gateway" {
  depends_on  = [module.cluster]
  description = "IP Addresses of the gateway."
  value       = module.cluster.gateway
}

output "control_plane_main" {
  depends_on  = [module.cluster]
  description = "Public Addresses of the main control plane node."
  value       = module.cluster.control_plane_main
}

output "node_pools" {
  depends_on  = [module.cluster]
  description = "IP Addresses of the worker node pools."
  value       = module.cluster.node_pools
}

output "total_monthly_costs" {
  depends_on  = [module.cluster]
  description = "Total monthly costs for running the cluster."
  value       = module.cluster.total_monthly_costs
}
