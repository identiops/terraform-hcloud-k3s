module "node_pools" {
  source     = "./node_pool"
  depends_on = [hcloud_server.control_plane_main, hcloud_network_subnet.subnet]

  # for_each          = { for k, v in var.node_pools : k => v if !v.is_control_plane }
  for_each               = var.node_pools
  cluster_name           = var.cluster_name
  name                   = each.key
  location               = var.location
  delete_protection      = var.delete_protection
  node_type              = each.value.type
  node_count             = each.value.count
  node_labels            = each.value.labels
  is_control_plane       = each.value.is_control_plane
  image                  = var.image
  ssh_keys               = [for k in hcloud_ssh_key.pub_keys : k.name]
  firewall_ids           = var.worker_node_firewall_ids
  hcloud_network_id      = hcloud_network.private.id
  subnet_ip_range        = hcloud_network_subnet.subnet.ip_range
  ip_offset              = var.ip_offset
  enable_public_net_ipv4 = var.enable_public_net_ipv4
  enable_public_net_ipv6 = var.enable_public_net_ipv6

  server_packages = concat(local.base_packages, var.additional_packages)
  runcmd = concat([
    local.security_setup,
    local.k8s_security_setup,
    local.package_updates,
    each.value.is_control_plane ?
    <<-EOT
      export K3S_URL="https://${hcloud_server_network.control_plane_main.ip}:6443"
      ${local.k3s_install~}
      sh -s - server \
      ${local.control_plane_arguments~}
      ${!each.value.schedule_workloads && each.value.is_control_plane ? "--node-taint node-role.kubernetes.io/control-plane=true:NoExecute" : ""}  %{for k, v in each.value.taints} --node-taint "${k}:${v}" %{endfor}  \
      ${var.control_plane_k3s_additional_options}  %{for key, value in var.control_plane_main_labels} --node-label=${key}=${value} %{endfor} %{for key, value in local.kube-apiserver-args} --kube-apiserver-arg=${key}=${value} %{endfor~}
      EOT
    :
    <<-EOT
      export K3S_URL=https://${hcloud_server_network.control_plane_main.ip}:6443
      ${local.k3s_install~}
      sh -s - agent \
      ${local.common_arguments~}

      # ATTENTION: the empty line above is required!
      EOT
  ], var.additional_runcmd)
  additional_cloud_init = var.additional_cloud_init
  prices                = local.prices
}
