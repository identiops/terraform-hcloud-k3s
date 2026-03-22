# Copyright 2024, identinet GmbH. All rights reserved.
# SPDX-License-Identifier: MIT

resource "hcloud_server" "pool" {
  depends_on = [hcloud_placement_group.pool]

  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      name,
      image,
      location,
      network,
      ssh_keys,
      user_data,
    ]
  }

  count              = var.node_count
  name               = "${var.cluster_name}-${var.name}-${format("%0${var.node_count_width}d", count.index)}"
  delete_protection  = var.delete_protection
  rebuild_protection = var.delete_protection
  server_type        = var.node_type
  location           = var.location
  image              = var.image
  ssh_keys           = var.ssh_keys
  labels             = var.node_labels
  placement_group_id = hcloud_placement_group.pool.id
  user_data = format("%s\n%s\n%s", "#cloud-config", yamlencode({
    # Documentation: https://cloudinit.readthedocs.io/en/latest/reference
    # not sure if these settings are required here, now that the software installation is done later
    # network = {
    #   version = 1
    #   config = [
    #     {
    #       type = "physical"
    #       name = var.network_intreface
    #       subnets = [
    #         { type    = "dhcp"
    #           gateway = var.default_gateway
    #           dns_nameservers = [
    #             "1.1.1.1",
    #             "1.0.0.1",
    #           ]
    #         }
    #       ]
    #     },
    #   ]
    # }
    package_update  = false
    package_upgrade = false
    runcmd          = count.index == 0 && length(var.runcmd_first) > 0 ? var.runcmd_first : var.runcmd
    write_files = concat([
      {
        path        = "/usr/local/bin/check-cluster-readiness"
        content     = file("${path.module}/../templates/check-cluster-readiness")
        permissions = "0755"
      },
      {
        path = "/etc/systemd/network/00-default-route.network"
        content = templatefile("${path.module}/../templates/default-route.network",
          {
            default_gateway   = var.default_gateway
            network_interface = var.network_interface
        })
      },
      {
        path        = "/etc/rancher/k3s/registries.yaml"
        content     = yamlencode(var.registries)
        permissions = "0600"
      },
      {
        path    = "/etc/sysctl.d/90-kubelet.conf"
        content = file("${path.module}/../templates/90-kubelet.conf")
      },
      {
        path        = "/etc/sysctl.d/98-settings.conf"
        content     = join("\n", formatlist("%s=%s", keys(var.sysctl_settings), values(var.sysctl_settings)))
        permissions = "0644"
      },
      {
        path = "/usr/local/bin/haproxy-k8s.nu"
        content = templatefile("${path.module}/../templates/haproxy-k8s.nu", {
          token = var.hcloud_token_read_only
          host  = var.k8s_ha_host
          port  = var.k8s_ha_port
        })
        permissions = "0700"
      },
      {
        path    = "/etc/systemd/system/haproxy-k8s.service"
        content = file("${path.module}/../templates/haproxy-k8s.service")
      },
      {
        path    = "/etc/systemd/system/haproxy-k8s.timer"
        content = file("${path.module}/../templates/haproxy-k8s.timer")
      },
    ], local.k3s_config_files)
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
  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      name,
    ]
  }

  name   = "${var.cluster_name}-${var.name}"
  type   = "spread"
  labels = var.node_labels
}

locals {
  costs_node = [for server_type in var.prices.server_types :
    [for price in server_type.prices :
      { net = tonumber(price.price_monthly.net), gross = tonumber(price.price_monthly.gross) } if price.location == var.location
    ][0] if server_type.name == var.node_type
  ][0]

  k3s_server_only_keys = toset([
    "cluster-cidr",
    "service-cidr",
    "disable",
    "disable+",
    "disable-cloud-controller",
    "disable-kube-proxy",
    "egress-selector-mode",
    "embedded-registry",
    "flannel-backend",
    "kube-apiserver-arg",
  ])

  k3s_critical_keys = toset([
    "disable-cloud-controller",
    "disable-kube-proxy",
    "flannel-backend",
    "egress-selector-mode",
  ])

  k3s_config_user = {
    for key, value in var.k3s_config : key => value
    if !contains(local.k3s_critical_keys, key)
  }

  k3s_config_critical = {
    "disable+"             = ["cloud-controller", "network-policy", "kube-proxy"]
    "flannel-backend"      = "none"
    "egress-selector-mode" = "disabled"
  }

  k3s_config_agent_base = {
    for key, value in merge(var.k3s_config_default, local.k3s_config_user) : key => value
    if !contains(local.k3s_server_only_keys, key)
  }

  k3s_config_control_plane_default = merge(
    var.k3s_config_default,
    length(var.kube_apiserver_args) > 0 ? { kube-apiserver-arg = [for k, v in var.kube_apiserver_args : "${k}=${v}"] } : {}
  )

  k3s_config_files = var.is_control_plane ? concat([
    {
      path        = "/etc/rancher/k3s/config.yaml.d/00-default.yaml"
      content     = yamlencode(local.k3s_config_control_plane_default)
      permissions = "0644"
    }
    ], length(local.k3s_config_user) > 0 ? [
    {
      path        = "/etc/rancher/k3s/config.yaml.d/10-user.yaml"
      content     = yamlencode(local.k3s_config_user)
      permissions = "0644"
    }
    ] : [], [
    {
      path        = "/etc/rancher/k3s/config.yaml.d/99-critical.yaml"
      content     = yamlencode(local.k3s_config_critical)
      permissions = "0644"
    }
    ]) : [
    {
      path        = "/etc/rancher/k3s/config.yaml.d/00-default.yaml"
      content     = yamlencode(local.k3s_config_agent_base)
      permissions = "0644"
    }
  ]
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

variable "sysctl_settings" {
  description = "Systctl settings, see `sysctl -a`"
  type        = map(string)
}

variable "registries" {
  description = "Registry mirror and authentication configuration. See https://docs.k3s.io/installation/private-registry"
  type = object({
    mirrors = optional(map(any))
    configs = optional(map(any))
  })
  default = {}
}

variable "k8s_ha_host" {
  description = "Kubernetes HA Host."
  type        = string
}

variable "k8s_ha_port" {
  description = "Kubernetes HA Host."
  type        = number
}

variable "hcloud_token_read_only" {
  description = "Hetzner cloud auth token, read only - used by the gateway and all cluster servers to proxy kubernetes traffic to control plane nodes."
  type        = string
  sensitive   = true
}

variable "delete_protection" {
  description = "Prevent cluster nodes from manual deletion. Is lifted automatically when cluster is destroyed. See https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server#delete_protection"
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

variable "runcmd_first" {
  description = "Installation instructions for the first node in the pool."
  type        = list(string)
  default     = []
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

variable "node_count_width" {
  description = "Width of the number in the nodes' names."
  type        = number
}

variable "node_type" {
  description = "Node type (size)."
  type        = string
  validation {
    condition     = can(regex("^(cpx|cx|cax|ccx)[0-9]+$", var.node_type))
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

variable "default_gateway" {
  description = "Default gateway."
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

variable "network_interface" {
  description = "Network interface name"
  type        = string
}

variable "prices" {
  description = "List of prices."
  type        = any
}

variable "is_control_plane" {
  description = "Does node pool contain control plane node?"
  type        = bool
}

variable "k3s_config_default" {
  description = "Default k3s configuration for the module."
  type        = any
  default     = {}
}

variable "k3s_config" {
  description = "User-provided k3s configuration (merged with defaults)."
  type        = any
  default     = {}
}

variable "kube_apiserver_args" {
  description = "Kube API server arguments for OIDC configuration."
  type        = map(string)
  default     = {}
}

output "location" {
  description = "Location of the node pool."
  value       = var.location
}

output "node_count" {
  description = "Number of nodes in the pool."
  value       = var.node_count
}

output "labels" {
  description = "Node pool labels."
  value       = var.node_labels
}

output "type" {
  description = "Server type."
  value       = var.node_type
}

output "is_control_plane" {
  description = "Does node pool contain control plane node?"
  value       = var.is_control_plane
}

output "nodes" {
  description = "Map of servers keyed by server name."
  value       = { for server in hcloud_server.pool : server.name => server }
}

output "costs" {
  description = "Monthly costs for this node pool."
  value = {
    net   = local.costs_node.net * var.node_count
    gross = local.costs_node.gross * var.node_count
  }
}

output "server_ids" {
  description = "List of server IDs for this node pool."
  value       = hcloud_server.pool[*].id
}
