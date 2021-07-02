provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_network" "private" {
  name     = var.cluster_name
  ip_range = "10.0.0.0/8"
}

resource "hcloud_network_subnet" "subnet" {
  network_id   = hcloud_network.private.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.0.0/24"
}

resource "random_string" "k3s_token" {
  length  = 48
  upper   = false
  special = false
}

module "floating_ip" {
  source = "./modules/floating_ip"

  cluster_name  = var.cluster_name
  home_location = substr(var.datacenter, 0, 4)

  for_each = var.floating_ips
  ip_type  = each.key
  ip_count = each.value
}

module "master" {
  source = "./modules/master"

  cluster_name = var.cluster_name
  datacenter   = var.datacenter
  image        = var.image
  node_type    = var.master_type
  ssh_keys     = var.ssh_keys

  hcloud_network_id = hcloud_network.private.id
  hcloud_subnet_id  = hcloud_network_subnet.subnet.id

  k3s_token   = random_string.k3s_token.result
  k3s_channel = var.k3s_channel

  hcloud_token = var.hcloud_token

  additional_user_data = var.master_user_data
}

module "node_group" {
  source = "./modules/node_group"

  cluster_name         = var.cluster_name
  datacenter           = var.datacenter
  image                = var.image
  ssh_keys             = var.ssh_keys
  master_internal_ipv4 = module.master.master_internal_ipv4
  floating_ips         = module.floating_ip

  hcloud_subnet_id = hcloud_network_subnet.subnet.id

  k3s_token   = random_string.k3s_token.result
  k3s_channel = var.k3s_channel

  for_each   = var.node_groups
  node_type  = each.key
  node_count = each.value

  additional_user_data = var.node_user_data
}

module "kubeconfig" {
  source       = "./modules/kubeconfig"
  cluster_name = var.cluster_name
  master_ipv4  = module.master.master_ipv4
}

