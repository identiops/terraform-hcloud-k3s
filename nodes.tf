resource "hcloud_server" "node" {
  depends_on = [hcloud_server.control_plane_master, hcloud_network_subnet.subnet]

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [user_data, image]
  }

  for_each    = var.nodes
  name        = "${var.cluster_name}-${each.key}"
  server_type = each.value.server_type
  datacenter  = var.datacenter
  image       = each.value.image
  ssh_keys    = var.ssh_keys
  labels      = var.node_labels
  user_data = format("%s\n%s\n%s", "#cloud-config", yamlencode({
    package_update  = true
    package_upgrade = true
    packages        = concat(local.server_base_packages, var.server_additional_packages)
    runcmd = concat([
      <<-EOT
      ${local.k3s_install~} \
      K3S_URL=https://${hcloud_server_network.control_plane_master.ip}:6443 \
      sh -s - agent \
      ${local.common_arguments}
      EOT
    ], var.additional_runcmd)
    }),
    yamlencode(var.additional_cloud_init)
  )

  firewall_ids = var.node_firewall_ids

  network {
    network_id = hcloud_network.private.id
    ip         = cidrhost(hcloud_network_subnet.subnet.ip_range, var.ip_offset + each.value.ip_index)
  }
}

resource "hcloud_server_network" "node" {
  depends_on = [hcloud_server.node]
  for_each   = hcloud_server.node
  server_id  = each.value.id
  subnet_id  = hcloud_network_subnet.subnet.id
}
