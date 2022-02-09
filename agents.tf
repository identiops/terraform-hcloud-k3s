module "node_group" {
  source = "./modules/node_group"

  cluster_name                       = var.cluster_name
  datacenter                         = var.datacenter
  image                              = var.image
  ssh_keys                           = var.ssh_keys
  control_plane_master_internal_ipv4 = hcloud_server_network.control_plane_master.ip
  floating_ips                       = module.floating_ip

  hcloud_network_id = hcloud_network.private.id
  hcloud_subnet_id  = hcloud_network_subnet.subnet.id
  subnet_ip_range   = hcloud_network_subnet.subnet.ip_range
  ip_offset         = 20

  k3s_token   = random_string.k3s_token.result
  k3s_version = var.k3s_version
  k3s_channel = var.k3s_channel

  for_each     = var.node_groups
  node_type    = each.key
  node_count   = each.value
  firewall_ids = var.node_group_firewall_ids

  additional_user_data = var.node_user_data
  depends_on           = [hcloud_server.control_plane_master]
}
