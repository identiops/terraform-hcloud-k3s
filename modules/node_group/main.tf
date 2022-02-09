locals {
  floating_ips = flatten([
    for type in var.floating_ips : [
      for output in type : [
        for floating_ip in output : [
          "${floating_ip}"
        ]
      ]
    ]
  ])
}

resource "hcloud_server" "node" {
  lifecycle {
    prevent_destroy = true
    ignore_changes  = [user_data]
  }

  count       = var.node_count
  name        = "${var.cluster_name}-${var.node_type}-${count.index}"
  server_type = var.node_type
  datacenter  = var.datacenter
  image       = var.image
  ssh_keys    = var.ssh_keys
  user_data = templatefile(
    "${path.module}/templates/init.sh", {
      k3s_token   = var.k3s_token
      k3s_version = var.k3s_version
      k3s_channel = var.k3s_channel

      master_internal_ipv4 = var.master_internal_ipv4

      floating_ips = local.floating_ips

      additional_user_data = var.additional_user_data
    }
  )
  firewall_ids = var.firewall_ids
}

resource "hcloud_server_network" "node" {
  count     = var.node_count
  server_id = hcloud_server.node[count.index].id
  subnet_id = var.hcloud_subnet_id
}

output "node_ipv4" {
  value = hcloud_server.node.*.ipv4_address
}

output "node_ipv6" {
  value = hcloud_server.node.*.ipv6_address
}

output "node_internal_ipv4" {
  value = hcloud_server_network.node.*.ip
}
