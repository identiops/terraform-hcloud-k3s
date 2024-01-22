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
  required_providers {
    hcloud = {
      # Documentation; https://registry.terraform.io/providers/hetznercloud/hcloud
      source  = "hetznercloud/hcloud"
      version = "~> 1.45.0"
    }
  }
  required_version = ">= 1.0"
}

###########################
#  Cluster configuration  #
###########################

module "cluster" {
  source       = "github.com/identiops/terraform-hcloud-k3s"
  hcloud_token = var.hcloud_token # INFO: Set via `export HCLOUD_TOKEN=xyz`

  # Cluster Settings
  # ----------------
  delete_protection = true # Must be set to false + `terraform apply` before destroying the cluster via `terraform destory`!
  cluster_name      = "production"
  location          = "nbg1"
  k3s_channel       = ""
  k3s_version       = "v1.28.5+k3s1"

  # General Settings
  # ----------------
  ssh_keys = {
    "john" = file("john.pub")
    "jane" = "ssh-xxxx xxxxx jane@example"
  }
  hcloud_ccm_driver_version = "v1.19.0"
  hcloud_csi_driver_version = "v2.6.0"
  calico_version            = "v3.27.0"

  # Control Plane Settings
  # ----------------------
  control_plane_main_schedule_workloads = true
  control_plane_main_server_type        = "cx41"
  additional_cloud_init = {
    timezone = "Europe/Berlin"
  }

  # Node Group Settings
  # -------------------
  # Map of worker node groups, key is server_type, value is count of nodes in group
  node_pools = {
    system = {
      is_control_plane   = true
      schedule_workloads = true
      type               = "cx41"
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
      type               = "cx41"
      count              = 3
      labels             = {}
      taints             = {}
    }
  }
}


##########
#  Code  #
##########

# INFO: Although we don't use the provider, it needs to be present here because
# of how terraform modules work https://www.terraform.io/docs/modules/providers.html
provider "hcloud" {
  token = var.hcloud_token
}

###############
#  Variables  #
###############

variable "hcloud_token" {
  description = "Hetzner cloud auth token"
  type        = string
  sensitive   = true
}

############
#  Output  #
############

output "gateway" {
  depends_on  = [module.cluster]
  description = "IP Addresses of the gateway"
  value       = module.cluster.gateway
}

output "control_plane_main" {
  depends_on  = [module.cluster]
  description = "Public Addresses of the main control plane node"
  value       = module.cluster.control_plane_main
}

output "node_pools" {
  depends_on  = [module.cluster]
  description = "IP Addresses of the worker node pools"
  value       = module.cluster.node_pools
}
