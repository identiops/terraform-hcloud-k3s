# output "control_plane_load_balancer" {
#   depends_on  = [hcloud_load_balancer.control_plane_load_balancer]
#   description = "IP Addresses of the load balancer"
#   value = {
#     public = {
#       ipv4 = var.enable_load_balancer ? hcloud_load_balancer.control_plane_load_balancer[0].ipv4 : "",
#       ipv6 = var.enable_load_balancer ? hcloud_load_balancer.control_plane_load_balancer[0].ipv6 : "",
#     },
#     private = [
#       var.enable_load_balancer ? hcloud_load_balancer.control_plane_load_balancer[0].network_ip : "",
#     ]
#   }
# }

output "gateway" {
  depends_on  = [hcloud_server.gateway]
  description = "IP Addresses of the gateway"
  value = {
    name = hcloud_server.gateway.name,
    type = var.gateway_server_type,
    public = {
      ipv4 = hcloud_server.gateway.ipv4_address,
      ipv6 = hcloud_server.gateway.ipv6_address,
    },
    private = [for network in hcloud_server.gateway.network : network.ip]
  }
}

output "control_plane_main" {
  depends_on  = [hcloud_server.control_plane_main]
  description = "IP Addresses of the control plane main node"
  value = {
    name = hcloud_server.control_plane_main.name,
    type = var.control_plane_main_server_type,
    public = {
      ipv4 = hcloud_server.control_plane_main.ipv4_address,
      ipv6 = hcloud_server.control_plane_main.ipv6_address
    },
    private = [for network in hcloud_server.control_plane_main.network : network.ip]
  }
}

output "node_pools" {
  depends_on  = [module.node_pools]
  description = "IP Addresses of the worker node pools"
  value       = module.node_pools
}
