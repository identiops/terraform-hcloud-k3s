# Copyright (c) 2021 Dustin Deus
# SPDX-License-Identifier: MIT
# Taken from: https://github.com/StarpTech/k-andy/blob/main/control_plane.tf

resource "hcloud_server" "control_plane" {
  lifecycle {
    prevent_destroy = false
    ignore_changes  = [user_data]
  }
  depends_on = [hcloud_server.control_plane_master]

  for_each = { for i in range(1, var.control_plane_server_count) : "#${i}" => i }

  name       = "${var.cluster_name}-control-plane-${each.value}"
  datacenter = var.datacenter
  # location    = element(var.server_locations, each.value)
  image       = var.image
  server_type = var.control_plane_server_type
  ssh_keys    = var.ssh_keys
  user_data = templatefile(
    "${path.module}/templates/control_plane.sh", {
      hcloud_token                        = var.hcloud_token
      control_plane_master_internal_ipv4  = hcloud_server_network.control_plane_master.ip
      control_plane_k3s_addtional_options = var.control_plane_k3s_addtional_options

      cluster_cidr_network = cidrsubnet(var.network_cidr, var.cluster_cidr_network_bits, var.cluster_cidr_network_offset)
      service_cidr_network = cidrsubnet(var.network_cidr, var.service_cidr_network_bits, var.service_cidr_network_offset)

      k3s_token   = random_string.k3s_token.result
      k3s_channel = var.k3s_channel
      k3s_version = var.k3s_version

      additional_user_data = var.control_plane_user_data
    }
  )

  firewall_ids = var.control_plane_firewall_ids

  network {
    network_id = hcloud_network.private.id
    ip         = cidrhost(hcloud_network_subnet.subnet.ip_range, each.value + 2)
  }
}

resource "hcloud_server_network" "control_plane" {
  for_each  = { for i in range(1, var.control_plane_server_count) : "#${i}" => i } // starts at 1 because master was 0
  subnet_id = hcloud_network_subnet.subnet.id
  server_id = hcloud_server.control_plane[each.key].id
  ip        = cidrhost(hcloud_network_subnet.subnet.ip_range, each.value + 2)
}
