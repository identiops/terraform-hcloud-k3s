output "gateway" {
  depends_on  = [hcloud_server.gateway]
  description = "IP Addresses of the gateway."
  value = {
    name   = hcloud_server.gateway.name,
    type   = var.gateway_server_type,
    labels = var.gateway_labels
    public = {
      ipv4 = hcloud_server.gateway.ipv4_address,
      ipv6 = hcloud_server.gateway.ipv6_address,
    },
    private = [for network in hcloud_server.gateway.network : network.ip]
    costs   = local.costs_gateway
  }
}

output "control_plane_main" {
  depends_on  = [hcloud_server.control_plane_main]
  description = "IP Addresses of the control plane main node."
  value = {
    name   = hcloud_server.control_plane_main.name,
    type   = var.control_plane_main_server_type,
    labels = local.control_plane_main_labels
    public = {
      ipv4 = hcloud_server.control_plane_main.ipv4_address,
      ipv6 = hcloud_server.control_plane_main.ipv6_address
    },
    private = [for network in hcloud_server.control_plane_main.network : network.ip]
    costs   = local.costs_main
  }
}

output "node_pools" {
  depends_on  = [module.node_pools]
  description = "IP Addresses of the worker node pools."
  value       = module.node_pools
}

output "total_monthly_costs" {
  depends_on  = [module.node_pools]
  description = "Total monthly costs for running the cluster."
  value = {
    net      = sum(concat([local.costs_gateway.net, local.costs_main.net], [for pool in module.node_pools : pool.costs.net]))
    gross    = sum(concat([local.costs_gateway.gross, local.costs_main.gross], [for pool in module.node_pools : pool.costs.gross]))
    currency = local.prices.currency
    vat_rate = tonumber(local.prices.vat_rate)
  }
}
