# Copyright (c) 2021 Dustin Deus
# SPDX-License-Identifier: MIT
# Taken from: https://github.com/StarpTech/k-andy/blob/main/control_plane.tf

resource "hcloud_server" "control_plane" {
  lifecycle {
    prevent_destroy = false
    ignore_changes  = [user_data, image]
  }
  depends_on = [hcloud_server.control_plane_master, hcloud_network_subnet.subnet]

  for_each = { for i in range(1, var.control_plane_server_count) : "#${i}" => i }

  name       = "${var.cluster_name}-control-plane-${each.value}"
  datacenter = var.datacenter
  # location    = element(var.server_locations, each.value)
  image       = var.image
  server_type = var.control_plane_server_type
  ssh_keys    = var.ssh_keys
  labels      = var.control_plane_labels
  user_data = format("%s\n%s\n%s", "#cloud-config", yamlencode({
    package_update  = true
    package_upgrade = true
    packages        = concat(local.server_base_packages, var.server_additional_packages)
    runcmd = concat([
      <<-EOT
      ${local.k3s_install~} \
      K3S_URL=https://${hcloud_server_network.control_plane_master.ip}:6443 \
      sh -s - server \
      ${local.control_plane_arguments} \
      ${var.control_plane_k3s_additional_options} %{for key, value in local.kube-apiserver-args~} --kube-apiserver-arg=${key}=${value} %{~endfor~}
      EOT
    ], var.additional_runcmd)
    }),
    yamlencode(var.additional_cloud_init)
  )

  firewall_ids = var.control_plane_firewall_ids

  network {
    network_id = hcloud_network.private.id
    ip         = cidrhost(hcloud_network_subnet.subnet.ip_range, each.value + 10 + 2)
  }
}

resource "hcloud_server_network" "control_plane" {
  for_each  = { for i in range(1, var.control_plane_server_count) : "#${i}" => i } // starts at 1 because master was 0
  subnet_id = hcloud_network_subnet.subnet.id
  server_id = hcloud_server.control_plane[each.key].id
  ip        = cidrhost(hcloud_network_subnet.subnet.ip_range, each.value + 10 + 2)
}
