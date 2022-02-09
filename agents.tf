module "node_group" {
  source = "./modules/node_group"

  cluster_name         = var.cluster_name
  datacenter           = var.datacenter
  image                = var.image
  ssh_keys             = var.ssh_keys
  master_internal_ipv4 = hcloud_server.control_plane_master.ipv4_address
  floating_ips         = module.floating_ip

  hcloud_subnet_id = hcloud_network_subnet.subnet.id

  k3s_token   = random_string.k3s_token.result
  k3s_version = var.k3s_version
  k3s_channel = var.k3s_channel

  for_each     = var.node_groups
  node_type    = each.key
  node_count   = each.value
  firewall_ids = var.node_group_firewall_ids

  additional_user_data = var.node_user_data
}
