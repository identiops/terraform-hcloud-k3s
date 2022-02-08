resource "hcloud_server" "master" {
  name        = "${var.cluster_name}-master"
  datacenter  = var.datacenter
  image       = var.image
  server_type = var.node_type
  ssh_keys    = var.ssh_keys
  user_data = templatefile(
    "${path.module}/templates/init.sh", {
      hcloud_token   = var.hcloud_token
      hcloud_network = var.hcloud_network_id

      cluster_cidr_network = var.cluster_cidr_network
      service_cidr_network = var.service_cidr_network

      hcloud_csi_driver_install = var.hcloud_csi_driver_install
      hcloud_csi_driver_version = var.hcloud_csi_driver_version
      hcloud_ccm_driver_install = var.hcloud_ccm_driver_install
      hcloud_ccm_driver_version = var.hcloud_ccm_driver_version

      k3s_token   = var.k3s_token
      k3s_channel = var.k3s_channel
      k3s_version = var.k3s_version

      additional_user_data = var.additional_user_data
    }
  )
  keep_disk    = true
  firewall_ids = var.firewall_ids

  network {
    network_id = var.hcloud_network_id
    ip         = var.hcloud_network_ip
  }
}

resource "hcloud_server_network" "master" {
  server_id = hcloud_server.master.id
  subnet_id = var.hcloud_subnet_id
}

output "master_ipv4" {
  value = hcloud_server.master.ipv4_address
}

output "master_ipv6" {
  value = hcloud_server.master.ipv6_address
}

output "master_internal_ipv4" {
  value = hcloud_server_network.master.ip
}
