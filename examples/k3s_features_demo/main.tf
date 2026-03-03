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

# Note: Using local module for testing. For production use, switch to registry version:
# source = "identiops/k3s/hcloud"
# version = "6.2.6"

module "cluster" {
  source                 = "../../"
  hcloud_token           = var.hcloud_token
  hcloud_token_read_only = var.hcloud_token_read_only

  # Cluster Settings
  # ----------------
  delete_protection = true
  cluster_name      = "demo"
  default_location  = "nbg1"
  default_image     = "ubuntu-24.04"
  k3s_channel       = "stable"
  k3s_version       = "v1.32.1+k3s1"

  # k3s Features Configuration (New File-Based Configuration)
  # ------------------------------------------------
  # This demonstrates the new file-based configuration approach.
  # The module will create these configuration files:
  # - /etc/rancher/k3s/config.yaml.d/00-default.yaml (default config)
  # - /etc/rancher/k3s/config.yaml.d/10-user.yaml (feature enables/disables)
  # - /etc/rancher/k3s/config.yaml.d/20-nodepool.yaml (node-pool specific)
  # - /etc/rancher/k3s/config.yaml.d/10-{feature}-user.yaml (custom configs)
  k3s_features = {
    traefik = {
      enabled = true
    }
    servicelb = {
      enabled = true
    }
    "local-storage" = {
      enabled = true
    }
    "kube-proxy" = {
      enabled       = true
      custom_config = <<-EOF
        mode: "iptables"
        metricsBindAddress: "0.0.0.0:10249"
      EOF
    }
  }

  # SSH Keys for cluster nodes
  ssh_keys = {
    "demo-admin" = file("~/.ssh/id_ed25519.pub")
  }

  ssh_keys_kubeapi = {
    "demo-kubeapi" = "ssh-xxxx xxxxx kubeapi@example"
  }

  # Gateway Settings
  # ----------------------
  gateway_firewall_k8s_open = false
  gateway_server_type       = "cpx11"

  # Control Plane Settings
  # ----------------------
  additional_cloud_init = {
    timezone = "Europe/Berlin"
  }

  # Private registry configuration
  registries = {
    mirrors = {
      "*" = null
    }
    configs = {}
  }

  # Node Group Settings
  # -------------------
  node_pools = {
    system = {
      cluster_can_init = true
      cluster_init_action = {
        init = true
      }
      is_control_plane   = true
      schedule_workloads = false
      type               = "cpx21"
      count              = 3
      labels             = {}
      taints             = {}
    }
    workers = {
      is_control_plane   = false
      schedule_workloads = true
      type               = "cpx21"
      count              = 3
      count_width        = 1
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
  description = "Hetzner cloud auth token, read only - used by gateway and all cluster servers to proxy kubernetes traffic to control plane nodes."
  type        = string
  sensitive   = true
}


############
#  Output  #
############

output "gateway" {
  depends_on  = [module.cluster]
  description = "IP Addresses of gateway."
  value       = module.cluster.gateway
}

output "node_pools" {
  depends_on  = [module.cluster]
  description = "IP Addresses of worker node pools."
  value       = module.cluster.node_pools
}

output "total_monthly_costs" {
  depends_on  = [module.cluster]
  description = "Total monthly costs for running the cluster."
  value       = module.cluster.total_monthly_costs
}

output "k3s_features_status" {
  description = "Demonstration of k3s_features status"
  value       = module.cluster.k3s_features
}
