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
  cmd_node_ip          = "$(ip -4 -j a s dev ens10 | jq '.[0].addr_info[0].local' -r)"
  cmd_node_external_ip = "$(ip -4 -j a s dev eth0 | jq '.[0].addr_info[0].local' -r),$(ip -6 -j a s dev eth0 | jq '.[0].addr_info[0].local' -r)"
}

resource "hcloud_server" "node" {
  lifecycle {
    prevent_destroy = false
    ignore_changes  = [user_data]
  }

  count       = var.node_count
  name        = "${var.cluster_name}-${var.node_type}-${count.index}"
  server_type = var.node_type
  datacenter  = var.datacenter
  image       = var.image
  ssh_keys    = var.ssh_keys
  user_data = templatefile(
    "${path.module}/templates/node_init.tftpl", {
      apt_packages = var.apt_packages

      cmd_install_k3s = <<-EOT
      - >
        wget -qO- https://get.k3s.io |
        INSTALL_K3S_CHANNEL=${var.k3s_channel}
        INSTALL_K3S_VERSION=${var.k3s_version}
        K3S_TOKEN=${var.k3s_token}
        K3S_URL=https://${var.control_plane_master_internal_ipv4}:6443
        sh -s - agent
        --node-ip=${local.cmd_node_ip}
        --node-external-ip=${local.cmd_node_external_ip}
        --kubelet-arg 'cloud-provider=external'
      EOT

      additional_yaml      = var.additional_yaml
      additional_user_data = var.additional_user_data
      floating_ips         = local.floating_ips
    }
  )

  firewall_ids = var.firewall_ids

  network {
    network_id = var.hcloud_network_id
    ip         = cidrhost(var.subnet_ip_range, var.ip_offset + count.index)
  }
}

resource "hcloud_server_network" "node" {
  count     = var.node_count
  server_id = hcloud_server.node[count.index].id
  subnet_id = var.hcloud_subnet_id
  ip        = cidrhost(var.subnet_ip_range, var.ip_offset + count.index)
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
