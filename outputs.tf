output "control_plane_master_ipv4" {
  description = "Public IPv4 Address of the master node"
  value       = hcloud_server.control_plane_master.ipv4_address
}

output "control_plane_master_ipv6" {
  description = "Public IPv6 Address of the master node"
  value       = hcloud_server.control_plane_master.ipv6_address
}

output "control_plane_nodes_ipv4" {
  depends_on  = [hcloud_server.control_plane]
  description = "Public IPv4 Address of the control plane nodes in groups"
  value = {
    for type, n in hcloud_server.control_plane :
    type => n.ipv4_address
  }
}

output "control_plane_nodes_ipv6" {
  depends_on  = [hcloud_server.control_plane]
  description = "Public IPv6 Address of the control plane nodes in groups"
  value = {
    for type, n in hcloud_server.control_plane :
    type => n.ipv6_address
  }
}

output "nodes_ipv4" {
  depends_on  = [hcloud_server.node]
  description = "Public IPv4 Address of the worker nodes in groups"
  value = {
    for node in hcloud_server.node : node.name => node.ipv4_address
  }
}

output "nodes_ipv6" {
  depends_on  = [hcloud_server.node]
  description = "Public IPv6 Address of the worker nodes in groups"
  value = {
    for type, n in hcloud_server.node :
    type => n.ipv6_address
  }
}
