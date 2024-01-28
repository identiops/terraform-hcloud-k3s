# Copyright 2024, identinet GmbH. All rights reserved.
# SPDX-License-Identifier: MIT

output "gateway" {
  depends_on  = [hcloud_server.gateway]
  description = "IP Addresses of the gateway."
  value = {
    name     = hcloud_server.gateway.name,
    type     = hcloud_server.gateway.server_type,
    location = hcloud_server.gateway.location,
    image    = hcloud_server.gateway.image
    labels   = hcloud_server.gateway.labels != null ? { for k, v in hcloud_server.gateway.labels : k => v } : {}
    public = {
      ipv4 = hcloud_server.gateway.ipv4_address,
      ipv6 = hcloud_server.gateway.ipv6_address,
    },
    private = [for network in hcloud_server.gateway.network : network.ip]
    costs   = local.costs_gateway
  }
}

output "node_pools" {
  depends_on  = [module.node_pool_cluster_init, module.node_pools]
  description = "IP Addresses of the worker node pools."
  value       = merge(module.node_pool_cluster_init, module.node_pools)
}

output "total_monthly_costs" {
  depends_on  = [module.node_pool_cluster_init, module.node_pools]
  description = "Total monthly costs for running the cluster."
  value = {
    node_count = sum(concat([1, 1], [for pool in module.node_pools : pool.node_count]))
    net        = sum(concat([local.costs_gateway.net], [for pool in merge(module.node_pool_cluster_init, module.node_pools) : pool.costs.net]))
    gross      = sum(concat([local.costs_gateway.gross], [for pool in merge(module.node_pool_cluster_init, module.node_pools) : pool.costs.gross]))
    currency   = local.prices.currency
    vat_rate   = tonumber(local.prices.vat_rate)
  }
}
