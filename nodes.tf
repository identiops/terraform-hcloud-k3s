resource "hcloud_server" "node" {
  depends_on = [hcloud_server.control_plane_master, hcloud_network_subnet.subnet]

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [user_data]
  }

  for_each    = var.nodes
  name        = "${var.cluster_name}-${each.key}"
  server_type = each.value.server_type
  datacenter  = var.datacenter
  image       = var.image
  ssh_keys    = var.ssh_keys
  labels      = var.node_labels
  user_data = templatefile(
    "${path.module}/templates/node_init.tftpl", {
      apt_packages = var.apt_packages

      cmd_install_k3s = <<-EOT
      - >
        wget -qO- https://get.k3s.io |
        INSTALL_K3S_CHANNEL=${var.k3s_channel}
        INSTALL_K3S_VERSION=${var.k3s_version}
        K3S_TOKEN=${random_string.k3s_token.result}
        K3S_URL=https://${hcloud_server_network.control_plane_master.ip}:6443
        sh -s - agent
        --node-ip=${local.cmd_node_ip}
        --node-external-ip=${local.cmd_node_external_ip}
        --kubelet-arg 'cloud-provider=external'
      EOT

      additional_yaml      = var.additional_yaml
      additional_user_data = var.node_user_data
    }
  )

  firewall_ids = var.node_firewall_ids

  network {
    network_id = hcloud_network.private.id
    ip         = cidrhost(hcloud_network_subnet.subnet.ip_range, var.ip_offset + each.value.ip_index)
  }
}

resource "hcloud_server_network" "node" {
  depends_on = [hcloud_server.node]
  for_each  = hcloud_server.node
  server_id = each.value.id
  subnet_id = hcloud_network_subnet.subnet.id
}
