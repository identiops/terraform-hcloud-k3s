output "master_ipv4" {
  depends_on  = [module.master]
  description = "Public IPv4 Address of the master node"
  value       = module.master.master_ipv4
}

output "master_ipv6" {
  depends_on  = [module.master]
  description = "Public IPv6 Address of the master node"
  value       = module.master.master_ipv6
}

output "nodes_ipv4" {
  depends_on  = [module.node_group]
  description = "Public IPv4 Address of the worker nodes in groups"
  value = {
    for type, n in module.node_group :
    type => n.node_ipv4
  }
}

output "nodes_ipv6" {
  depends_on  = [module.node_group]
  description = "Public IPv6 Address of the worker nodes in groups"
  value = {
    for type, n in module.node_group :
    type => n.node_ipv6
  }
}

output "floating_ips" {
  depends_on  = [module.floating_ip]
  description = "Floating IP addresses that can be used for ingress"
  value = {
    for type, ip in module.floating_ip :
    type => ip.floating_ip
  }
}
