# Terraform language documentation: https://www.terraform.io/docs/language/index.html
# HCL language specification: https://github.com/hashicorp/hcl/blob/main/hclsyntax/spec.md
# Module documentation: https://registry.terraform.io/modules/identiops/k3s/hcloud/latest
# Copyright 2024, identinet GmbH. All rights reserved.
# SPDX-License-Identifier: MIT

###########################
#  Backend and Providers  #
###########################

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
  required_version = "~> 1.0"
}

###########################
#  Cluster configuration  #
###########################

module "cluster" {
  source = "../.."

  hcloud_token           = var.hcloud_token
  hcloud_token_read_only = var.hcloud_token_read_only

  # Cluster Settings
  # ----------------
  delete_protection = true
  cluster_name      = "helm-traefik"
  default_location  = "nbg1"
  default_image     = "ubuntu-24.04"
  k3s_version       = "v1.32.1+k3s1"

  # General Settings
  # ----------------
  ssh_keys = {
    "admin" = file("~/.ssh/id_ed25519.pub")
  }

  # Gateway Settings
  # ----------------
  gateway_firewall_k8s_open = false
  gateway_server_type       = "cpx11"

  additional_cloud_init = {
    timezone = "Europe/Berlin"
  }

  # k3s Configuration - Enable helm-controller and traefik
  # ------------------------------------------------------
  # This overrides the module defaults that disable helm-controller and traefik.
  # The module default disable list is:
  #   ["cloud-controller", "network-policy", "local-storage", "metrics-server", "servicelb", "traefik", "helm-controller"]
  # By setting disable = [], we re-enable all components that were disabled.
  k3s_config = {
    disable = []
  }

  # Node Pool Settings
  # ------------------
  node_pools = {
    system = {
      cluster_can_init = true
      cluster_init_action = {
        init = true
      }
      is_control_plane   = true
      schedule_workloads = false
      type               = "cpx33" # See available types https://docs.hetzner.com/cloud/servers/overview#shared-vcpu
      count              = 3
      labels             = {}
      taints             = {}
    }
    workers = {
      is_control_plane   = false
      schedule_workloads = true
      type               = "cpx33" # See available types https://docs.hetzner.com/cloud/servers/overview#shared-vcpu
      count              = 3
      count_width        = 2
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

variable "hcloud_token_read_only" {
  description = "Hetzner cloud auth token, read only."
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

output "node_pools" {
  depends_on  = [module.cluster]
  description = "IP Addresses of the node pools."
  value       = module.cluster.node_pools
}

output "total_monthly_costs" {
  depends_on  = [module.cluster]
  description = "Total monthly costs for running the cluster."
  value       = module.cluster.total_monthly_costs
}
