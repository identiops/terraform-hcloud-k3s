# Terraform language documentation: https://www.terraform.io/docs/language/index.html
# HCL language specification: https://github.com/hashicorp/hcl/blob/main/hclsyntax/spec.md

###########################
#  Backend and Providers  #
###########################

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
  required_version = ">= 1.0"
}

###########################
#  Cluster configuration  #
###########################

module "cluster" {
  # source       = "github.com/identiops/terraform-hcloud-k3s?ref=2.0.5"
  source       = "identiops/k3s/hcloud"
  version = "2.0.5"
  hcloud_token = var.hcloud_token # INFO: Set via `export TF_VAR_hcloud_token=xyz

  # Cluster Settings
  # ----------------
  delete_protection = true # Must be set to false + `terraform apply` before destroying the cluster via `terraform destory`!
  cluster_name      = "prod"
  location          = "nbg1"         # See available locations https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server#location
  image             = "ubuntu-22.04" # See `HCLOUD_TOKEN=XXXX; curl -H \"Authorization: Bearer $HCLOUD_TOKEN\" https://api.hetzner.cloud/v1/images | jq -r .images[].name | sort`
  k3s_version       = "v1.28.5+k3s1" # See available versions, https://update.k3s.io/v1-release/channels regular images: https://hub.docker.com/r/rancher/k3s/tags upgrade images: https://hub.docker.com/r/rancher/k3s-upgrade/tags

  # General Settings
  # ----------------
  ssh_keys = {
    "john" = file("john.pub")
    "jane" = "ssh-xxxx xxxxx jane@example"
  }
  cilium_version                    = "1.14.5"  # See available versions https://github.com/cilium/cilium
  hcloud_ccm_driver_chart_version   = "1.19.0"  # Check k8s compatibility https://github.com/hetznercloud/hcloud-cloud-controller-manager#versioning-policy
  hcloud_csi_driver_chart_version   = "2.6.0"   # Check k8s compatibility https://github.com/hetznercloud/csi-driver/blob/main/docs/kubernetes/README.md#versioning-policy
  kured_chart_version               = "5.4.1"   # See available versions https://artifacthub.io/packages/helm/kured/kured
  metrics_server_chart_version      = "3.11.0"  # See available versions https://artifacthub.io/packages/helm/metrics-server/metrics-server
  system_upgrade_controller_version = "v0.13.2" # See available versions https://github.com/rancher/system-upgrade-controller

  # Control Plane Settings
  # ----------------------
  additional_cloud_init = {
    timezone = "Europe/Berlin" # See available time zones https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List
  }

  # Node Group Settings
  # -------------------
  # Map of worker node groups, key is server_type, value is count of nodes in group
  node_pools = {
    system = {
      cluster_can_init = true # Required for one node pool to perform initializing actions.
      cluster_init_action = {
        # `init` must be `true` for the first run of `terraform apply.
        # For later runs it should be set to `false` to prevent any accidential
        # reinitialization of the cluster, e.g. when the first node of this pool
        # is manually deleted via the management console.
        init = true,
      }
      is_control_plane   = true
      schedule_workloads = true
      type               = "cx21" # See available types https://docs.hetzner.com/cloud/servers/overview#shared-vcpu
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
      type               = "cx21" # See available types https://docs.hetzner.com/cloud/servers/overview#shared-vcpu
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
