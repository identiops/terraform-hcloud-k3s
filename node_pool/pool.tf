terraform {
  required_providers {
    hcloud = {
      # Documentation; https://registry.terraform.io/providers/hetznercloud/hcloud
      source  = "hetznercloud/hcloud"
      version = "1.45.0"
    }
  }
  required_version = ">= 1.0"
}

resource "hcloud_server" "pool" {
  depends_on = [hcloud_placement_group.pool]

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [user_data, image]
  }

  count              = var.node_count
  name               = "${var.cluster_name}-${var.name}-${format("%02d", count.index)}"
  delete_protection  = var.delete_protection
  rebuild_protection = var.delete_protection
  server_type        = var.node_type
  location           = var.location
  image              = var.image
  ssh_keys           = var.ssh_keys
  labels             = var.node_labels
  placement_group_id = hcloud_placement_group.pool.id
  user_data = format("%s\n%s\n%s", "#cloud-config", yamlencode({
    # not sure if I need these settings now that the software installation is done later
    network = {
      version = 1
      config = [
        {
          type = "physical"
          name = "ens10"
          subnets = [
            { type    = "dhcp"
              gateway = "10.0.0.1"
              dns_nameservers = [
                "1.1.1.1",
                "1.0.0.1",
              ]
            }
          ]
        },
      ]
    }
    package_update  = false
    package_upgrade = false
    runcmd          = var.runcmd
    write_files = [
      {
        path    = "/etc/systemd/network/default-route.network"
        content = file("${path.module}/../templates/default-route.network")
      },
      {
        path    = "/etc/sysctl.d/99-increase-inotify-limits"
        content = <<-EOT
          fs.inotify.max_user_instances = 512;
          fs.inotify.max_user_watches = 262144;
        EOT
      },
    ]
    }),
    yamlencode(var.additional_cloud_init)
  )

  firewall_ids = var.firewall_ids

  public_net {
    ipv4_enabled = var.enable_public_net_ipv4
    ipv6_enabled = var.enable_public_net_ipv6
  }

  network {
    network_id = var.hcloud_network_id
  }
}

resource "hcloud_placement_group" "pool" {
  name   = "${var.cluster_name}-${var.name}"
  type   = "spread"
  labels = var.node_labels
}

locals {
  costs_node = [for server_type in var.prices.server_types : [for price in server_type.prices : { net = tonumber(price.price_monthly.net), gross = tonumber(price.price_monthly.gross) } if price.location == var.location][0] if server_type.name == var.node_type][0]
}

variable "name" {
  description = "Name of node pool."
  type        = string
  validation {
    condition = (
      can(regex("^[a-z0-9-]+$", var.name))
    )
    error_message = "Node pool can't be named control-plane and must only contain characters allowed in DNS names (`^[a-z0-9-]+$`)."
  }
}

variable "delete_protection" {
  description = "Prevent cluster nodes from manual deletion. Is lifted automatically when cluster is destroyed. See https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server#delete_protection"
  type        = bool
}

variable "is_control_plane" {
  description = "Is control plane node pool."
  type        = bool
}

variable "node_labels" {
  description = "Hetzner server labels for worker nodes."
  type        = map(string)
}

variable "enable_public_net_ipv4" {
  description = "Enable the assignment of a public IPv4 address (increases the costs per month)."
  type        = bool
}

variable "enable_public_net_ipv6" {
  description = "Enable the assignment of a public IPv6 address (increases the costs per month)."
  type        = bool
}

variable "location" {
  description = "Hetzner server location, see https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server#location"
  type        = string
}

variable "runcmd" {
  description = "Installation instructions."
  type        = list(string)
}

variable "cluster_name" {
  description = "Cluster name (prefix for all resource names)."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.cluster_name))
    error_message = "Cluster name must only contain characters allowed in DNS names (`^[a-z0-9-]+$`)."
  }
}

variable "node_count" {
  description = "Count on nodes in pool."
  type        = number
}

variable "node_type" {
  description = "Node type (size)."
  type        = string
  validation {
    condition     = can(regex("^(cp?x[1-5]1|cax[1-4]1|ccx[1-6]3)$", var.node_type))
    error_message = "Node type is not valid."
  }
}

variable "image" {
  description = "Node boot image."
  type        = string
}

variable "ssh_keys" {
  description = "Public SSH keys ids (list) used to login."
  type        = list(string)
}

variable "hcloud_network_id" {
  description = "IP Network id."
  type        = string
}

variable "firewall_ids" {
  description = "A list of firewall IDs to apply on the node."
  type        = list(number)
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

variable "prices" {
  description = "List of prices"
  type        = any
}

output "is_control_plane" {
  value = var.is_control_plane
}

output "type" {
  value = var.node_type
}

output "nodes" {
  value = {
    for n in hcloud_server.pool :
    n.name => {
      public = {
        ipv4 = var.enable_public_net_ipv4 ? n.ipv4_address : "",
        ipv6 = var.enable_public_net_ipv6 ? n.ipv6_address : ""
      },
      private = [for network in n.network : network.ip]
      costs   = local.costs_node
    }
  }
}

output "costs" {
  description = "Total monthly costs for running the cluster"
  value = {
    net   = local.costs_node.net * var.node_count
    gross = local.costs_node.gross * var.node_count
  }
}
