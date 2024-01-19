# Copyright (c) 2021 Dustin Deus
# SPDX-License-Identifier: MIT
# Taken from: https://github.com/StarpTech/k-andy/blob/main/control_plane.tf

# resource "hcloud_server" "control_plane" {
#   depends_on = [hcloud_server.control_plane_main]
#
#   lifecycle {
#     prevent_destroy = false
#     ignore_changes  = [user_data, image]
#   }
#
#   for_each = { for i in range(1, var.control_plane_server_count) : "#${i}" => i }
#
#   name               = "${var.cluster_name}-control-plane-${format("%02d", each.value)}"
#   delete_protection  = var.delete_protection
#   rebuild_protection = var.delete_protection
#   location           = var.location
#   image              = var.image
#   server_type        = var.control_plane_server_type
#   ssh_keys           = [for k in hcloud_ssh_key.pub_keys : k.name]
#   labels             = var.control_plane_labels
#   placement_group_id = hcloud_placement_group.control_plane.id
#   user_data = format("%s\n%s\n%s", "#cloud-config", yamlencode({
#     package_update  = true
#     package_upgrade = true
#     packages        = concat(local.base_packages, var.additional_packages)
#     runcmd = concat([
#       local.security_setup,
#       <<-EOT
#       ${local.k3s_install~} \
#       K3S_URL=https://${hcloud_server_network.control_plane_main.ip}:6443 \
#       sh -s - server \
#       ${local.control_plane_arguments} \
#       ${var.control_plane_schedule_workloads ? "--node-taint CriticalAddonsOnly=true:NoExecute" : ""}  \
#       ${var.control_plane_k3s_additional_options~} \
#         %{for key, value in local.kube-apiserver-args~} --kube-apiserver-arg=${key}=${value} %{~endfor~}
#       EOT
#     ], var.additional_runcmd)
#     }),
#     yamlencode(var.additional_cloud_init)
#   )
#
#   firewall_ids = var.control_plane_firewall_ids
#
#   public_net {
#     ipv4_enabled = var.enable_public_net_ipv4
#     ipv6_enabled = var.enable_public_net_ipv6
#   }
#
#   network {
#     network_id = hcloud_network.private.id
#     ip         = cidrhost(hcloud_network_subnet.subnet.ip_range, each.value + 10 + 2)
#   }
# }
