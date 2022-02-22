resource "hcloud_server" "control_plane_master" {
  lifecycle {
    prevent_destroy = false
    ignore_changes  = [user_data]
  }
  depends_on = [hcloud_network.private, hcloud_network_subnet.subnet]

  name        = "${var.cluster_name}-control-plane-master"
  datacenter  = var.datacenter
  image       = var.image
  server_type = var.control_plane_server_type
  ssh_keys    = var.ssh_keys
  user_data = templatefile(
    "${path.module}/templates/control_plane_master_init.yml.tftpl", {
      path_module  = path.module
      apt_packages = var.apt_packages

      hcloud_token                        = var.hcloud_token
      hcloud_network                      = hcloud_network.private.id
      control_plane_k3s_addtional_options = var.control_plane_k3s_addtional_options

      cluster_cidr_network = cidrsubnet(var.network_cidr, var.cluster_cidr_network_bits - 8, var.cluster_cidr_network_offset)
      service_cidr_network = cidrsubnet(var.network_cidr, var.service_cidr_network_bits - 8, var.service_cidr_network_offset)
      cmd_node_ip          = "$(ip -4 -j a s dev ens10 | jq '.[0].addr_info[0].local' -r)"
      cmd_node_external_ip = "$(ip -4 -j a s dev eth0 | jq '.[0].addr_info[0].local' -r),$(ip -6 -j a s dev eth0 | jq '.[0].addr_info[0].local' -r)"

      kustomization_manifest = file("${path.module}/templates/kustomization.yml")
      calico_manifest = templatefile("${path.module}/templates/calico.yml", {
        cluster_cidr_network = local.cluster_cidr_network
      })

      hcloud_csi_driver_install = var.hcloud_csi_driver_install
      hcloud_csi_driver_version = var.hcloud_csi_driver_version
      hcloud_ccm_driver_install = var.hcloud_ccm_driver_install
      hcloud_ccm_driver_version = var.hcloud_ccm_driver_version

      k3s_token   = random_string.k3s_token.result
      k3s_channel = var.k3s_channel
      k3s_version = var.k3s_version

      additional_user_data = var.control_plane_master_user_data
    }
  )
  firewall_ids = var.control_plane_firewall_ids

  network {
    network_id = hcloud_network.private.id
    ip         = cidrhost(hcloud_network_subnet.subnet.ip_range, 10 + 2)
  }
}

resource "hcloud_server_network" "control_plane_master" {
  server_id = hcloud_server.control_plane_master.id
  subnet_id = hcloud_network_subnet.subnet.id
  ip        = cidrhost(hcloud_network_subnet.subnet.ip_range, 10 + 2)
}
