# Copyright (c) 2021 Dustin Deus
# SPDX-License-Identifier: MIT
# Taken from: https://github.com/StarpTech/k-andy/blob/main/control_plane.tf

resource "hcloud_server" "control_plane" {
  lifecycle {
    prevent_destroy = false
    ignore_changes  = [user_data]
  }
  depends_on = [hcloud_server.control_plane_master, hcloud_network_subnet.subnet]

  for_each = { for i in range(1, var.control_plane_server_count) : "#${i}" => i }

  name       = "${var.cluster_name}-control-plane-${each.value}"
  datacenter = var.datacenter
  # location    = element(var.server_locations, each.value)
  image       = var.image
  server_type = var.control_plane_server_type
  ssh_keys    = var.ssh_keys
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
        sh -s - server
        --flannel-backend=none
        --disable-network-policy
        --cluster-cidr=${local.cluster_cidr_network}
        --service-cidr=${local.service_cidr_network}
        --node-ip=${local.cmd_node_ip}
        --node-external-ip=${local.cmd_node_external_ip}
        --disable local-storage
        --disable-cloud-controller
        --disable traefik
        --disable servicelb
        --kubelet-arg 'cloud-provider=external'
        ${var.control_plane_k3s_addtional_options}
        %{for key, value in local.kube-apiserver-args~}
--kube-apiserver-arg=${key}=${value}
        %{endfor~}
      EOT

      additional_yaml      = var.additional_yaml
      additional_user_data = var.control_plane_user_data
    }
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
