resource "hcloud_server" "control_plane_master" {
  lifecycle {
    prevent_destroy = true
    ignore_changes  = [user_data]
  }
  depends_on = [hcloud_network.private, hcloud_network_subnet.subnet]

  name        = "${var.cluster_name}-control-plane-master"
  datacenter  = var.datacenter
  image       = var.image
  server_type = var.master_type
  ssh_keys    = var.ssh_keys
  user_data = templatefile(
    "${path.module}/templates/control_plane_master.sh", {
      hcloud_token   = var.hcloud_token
      hcloud_network = hcloud_network.private.id

      cluster_cidr_network = cidrsubnet(var.network_cidr, var.cluster_cidr_network_bits, var.cluster_cidr_network_offset)
      service_cidr_network = cidrsubnet(var.network_cidr, var.service_cidr_network_bits, var.service_cidr_network_offset)

      hcloud_csi_driver_install = var.hcloud_csi_driver_install
      hcloud_csi_driver_version = var.hcloud_csi_driver_version
      hcloud_ccm_driver_install = var.hcloud_ccm_driver_install
      hcloud_ccm_driver_version = var.hcloud_ccm_driver_version

      k3s_token   = random_string.k3s_token.result
      k3s_channel = var.k3s_channel
      k3s_version = var.k3s_version

      additional_user_data = var.master_user_data
    }
  )
  keep_disk    = true
  firewall_ids = var.master_firewall_ids

  network {
    network_id = hcloud_network.private.id
    ip         = var.master_internal_ipv4
  }
}

resource "hcloud_server_network" "control_plane_master" {
  server_id = hcloud_server.control_plane_master.id
  subnet_id = hcloud_network_subnet.subnet.id
}
