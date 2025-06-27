# Copyright 2024, identinet GmbH. All rights reserved.
# SPDX-License-Identifier: MIT

module "node_pools_network_interface" {
  source   = "./network_interface"
  for_each = { for k, v in var.node_pools : k => v if !v.cluster_can_init }
  image    = each.value.image != "" ? each.value.image : var.default_image
  any      = each.value
}

module "node_pools" {
  source     = "./node_pool"
  depends_on = [module.node_pool_cluster_init]

  for_each               = module.node_pools_network_interface
  cluster_name           = var.cluster_name
  name                   = each.key
  hcloud_token_read_only = var.hcloud_token_read_only
  location               = each.value.any.location != "" ? each.value.any.location : var.default_location
  delete_protection      = var.delete_protection
  sysctl_settings        = var.sysctl_settings
  registries             = var.registries
  node_type              = each.value.any.type
  node_count             = each.value.any.count
  node_count_width       = each.value.any.count_width
  node_labels            = merge(each.value.any.labels, each.value.any.is_control_plane ? { "control-plane" = "true" } : {})
  image                  = each.value.image
  network_interface      = each.value.network_interface
  ssh_keys               = [for k in hcloud_ssh_key.pub_keys : k.name]
  firewall_ids           = each.value.any.is_control_plane ? var.control_plane_firewall_ids : var.worker_node_firewall_ids
  hcloud_network_id      = hcloud_network.private.id
  enable_public_net_ipv4 = var.enable_public_net_ipv4
  enable_public_net_ipv6 = var.enable_public_net_ipv6
  default_gateway        = local.default_gateway
  is_control_plane       = each.value.any.is_control_plane
  k8s_ha_host            = local.k8s_ha_host
  k8s_ha_port            = local.k8s_ha_port

  runcmd = concat([
    local.security_setup,
    each.value.any.is_control_plane ? local.control_plane_k8s_security_setup : "",
    local.k8s_security_setup,
    local.package_updates,
    local.haproxy_setup,
    local.k3s_url,
    each.value.any.is_control_plane ?
    <<-EOT
      ${local.k3s_install~}
      sh -s - server \
      ${local.control_plane_arguments~}
      --node-ip="$(ip -4 -j a s dev ${each.value.network_interface} | jq '.[0].addr_info[0].local' -r)" \
      ${!each.value.any.schedule_workloads ? "--node-taint CriticalAddonsOnly=true:NoExecute" : ""}  %{for k, v in each.value.any.taints} --node-taint "${k}:${v}" %{endfor}  \
      ${var.control_plane_k3s_additional_options}  %{for key, value in merge(each.value.any.labels, each.value.any.is_control_plane ? { "control-plane" = "true" } : {})} --node-label=${key}=${value} %{endfor} %{for key, value in local.kube-apiserver-args} --kube-apiserver-arg=${key}=${value} %{endfor}
      EOT
    :
    <<-EOT
      ${local.k3s_install~}
      sh -s - agent --node-ip="$(ip -4 -j a s dev ${each.value.network_interface} | jq '.[0].addr_info[0].local' -r)" ${local.common_arguments~}
      EOT
    ,
    local.dist_upgrade,
  ], var.additional_runcmd)
  additional_cloud_init = var.additional_cloud_init
  prices                = local.prices
}
