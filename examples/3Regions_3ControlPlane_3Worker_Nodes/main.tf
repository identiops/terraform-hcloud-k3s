# Terraform language documentation: https://www.terraform.io/docs/language/index.html
# HCL language specification: https://github.com/hashicorp/hcl/blob/main/hclsyntax/spec.md
# Copyright 2024, identinet GmbH. All rights reserved.
# SPDX-License-Identifier: MIT

###########################
#  Backend and Providers  #
###########################

terraform {
  # See Version Constraints: https://developer.hashicorp.com/terraform/language/expressions/version-constraints
  backend "local" {
    path = "terraform.tfstate"
  }
  # Example s3 configuration:
  # backend "s3" {
  #   bucket = "xxxxx-terraform"
  #   key    = "prod/terraform.tfstate"
  #   # access_key                  = {}
  #   # secret_key                  = {}
  #   # skip_get_ec2_platforms      = true
  #   region                      = "eu-central-2"
  #   skip_credentials_validation = true
  #   skip_metadata_api_check     = true
  #   skip_region_validation      = true
  #   skip_requesting_account_id  = true
  #   skip_s3_checksum            = true
  #   use_path_style              = true
  #   endpoints = {
  #     iam = "https://iam.eu-central-2.wasabisys.com" # special endpoint URL required, see https://wasabi-support.zendesk.com/hc/en-us/articles/360003362071-How-do-I-use-Terraform-with-Wasabi-
  #     sts = "https://sts.eu-central-2.wasabisys.com" # special endpoint URL required, see https://wasabi-support.zendesk.com/hc/en-us/articles/360003362071-How-do-I-use-Terraform-with-Wasabi-
  #     s3  = "https://s3.eu-central-2.wasabisys.com"  # special endpoint URL required, see https://wasabi-support.zendesk.com/hc/en-us/articles/360003362071-How-do-I-use-Terraform-with-Wasabi-
  #   }
  # }
  required_version = "~> 1.0"
}

###########################
#  Cluster configuration  #
###########################

module "cluster" {
  # source       = "github.com/identiops/terraform-hcloud-k3s?ref=3.0.6"
  source                 = "identiops/k3s/hcloud"
  version                = "3.0.6"
  hcloud_token           = var.hcloud_token           # INFO: Set via `export TF_VAR_hcloud_token=xyz`
  hcloud_token_read_only = var.hcloud_token_read_only # INFO: Set via `export TF_VAR_hcloud_token_read_only=abc`

  # Cluster Settings
  # ----------------
  delete_protection = true # Must be set to false + `terraform apply` before destroying the cluster via `terraform destory`!
  cluster_name      = "prod"
  default_location  = "nbg1"         # See available locations https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server#location
  default_image     = "ubuntu-24.04" # See `HCLOUD_TOKEN=XXXX; curl -H \"Authorization: Bearer $HCLOUD_TOKEN\" https://api.hetzner.cloud/v1/images | jq -r .images[].name | sort`
  k3s_version       = "v1.31.5+k3s1" # See available versions, https://update.k3s.io/v1-release/channels regular images: https://hub.docker.com/r/rancher/k3s/tags upgrade images: https://hub.docker.com/r/rancher/k3s-upgrade/tags

  # General Settings
  # ----------------
  ssh_keys = {
    "john" = file("~/.ssh/id_ed25519.pub")
    "jane" = "ssh-xxxx xxxxx jane@example"
  }

  # Control Plane Settings
  # ----------------------
  # Example s3 configuration:
  # S3 documentation  https://docs.k3s.io/cli/server
  # control_plane_k3s_init_additional_options = "--etcd-s3 --etcd-s3-region=${var.etcd_s3_region} --etcd-s3-endpoint=s3.${var.etcd_s3_region}.wasabisys.com --etcd-s3-access-key=${var.etcd_s3_access_key} --etcd-s3-secret-key=${var.etcd_s3_secret_key} --etcd-s3-bucket=${var.etcd_s3_bucket} --etcd-s3-folder=etcd/$(hostname)"
  # etcd tuning documentation for multi-region deployment: https://etcd.io/docs/v3.4/tuning/#time-parameters
  control_plane_k3s_additional_options = "--etcd-arg=heartbeat-interval=120 --etcd-arg=election-timeout=1200" # See https://etcd.io/docs/v3.4/tuning/#time-parameters
  additional_cloud_init = {
    timezone = "Europe/Berlin" # See available time zones https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List
  }

  # Node Group Settings
  # -------------------
  # Map of worker node groups, key is server_type, value is count of nodes in group
  node_pools = {
    system-nbg = {
      cluster_can_init = true # Required for one node pool to perform initializing actions.
      cluster_init_action = {
        # `init` must be `true` for the first run of `terraform apply.
        # For later runs it should be set to `false` to prevent any accidential
        # reinitialization of the cluster, e.g. when the first node of this pool
        # is manually deleted via the management console.
        init = true,
      }
      is_control_plane   = true
      schedule_workloads = false
      location           = "nbg1"
      type               = "cpx31" # See available types https://docs.hetzner.com/cloud/servers/overview#shared-vcpu
      count              = 1
      labels = {
        # "control-plane" = "yes"
      }
      taints = {
        # "MyTaint=true" = "NoSchedule"
      }
    }
    system-fsn = {
      cluster_can_init   = false # Required for one node pool to perform initializing actions.
      is_control_plane   = true
      schedule_workloads = false
      location           = "fsn1"
      type               = "cpx31" # See available types https://docs.hetzner.com/cloud/servers/overview#shared-vcpu
      count              = 1
      labels             = {}
      taints             = {}
    }
    system-hel = {
      cluster_can_init   = false # Required for one node pool to perform initializing actions.
      is_control_plane   = true
      schedule_workloads = false
      location           = "hel1"
      type               = "cpx31" # See available types https://docs.hetzner.com/cloud/servers/overview#shared-vcpu
      count              = 1
      labels             = {}
      taints             = {}
    }
    workers = {
      is_control_plane   = false
      schedule_workloads = true
      type               = "cpx31" # See available types https://docs.hetzner.com/cloud/servers/overview#shared-vcpu
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
  description = "Hetzner cloud auth token, read only - used by the gateway and all cluster servers to proxy kubernetes traffic to control plane nodes."
  type        = string
  sensitive   = true
}

# Example s3 configuraiton:
# variable "etcd_s3_region" {
#   type      = string
#   sensitive = true
# }
# 
# variable "etcd_s3_access_key" {
#   type      = string
#   sensitive = true
# }
# 
# variable "etcd_s3_secret_key" {
#   type      = string
#   sensitive = true
# }
# 
# variable "etcd_s3_bucket" {
#   type      = string
#   sensitive = true
# }

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
  description = "IP Addresses of the worker node pools."
  value       = module.cluster.node_pools
}

output "total_monthly_costs" {
  depends_on  = [module.cluster]
  description = "Total monthly costs for running the cluster."
  value       = module.cluster.total_monthly_costs
}
