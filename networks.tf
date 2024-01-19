resource "hcloud_network" "private" {
  name              = var.cluster_name
  ip_range          = var.network_cidr
  delete_protection = var.delete_protection
}

resource "hcloud_network_subnet" "subnet" {
  network_id   = hcloud_network.private.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = var.subnet_cidr
}
