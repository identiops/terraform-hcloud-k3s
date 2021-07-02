data "template_file" "ccm_manifest" {
  template = file("${path.module}/manifestos/hcloud-ccm-net.yaml")
}

data "template_file" "csi_manifest" {
  template = file("${path.module}/manifestos/hcloud-csi.yaml")
}

data "template_file" "master_init" {
  template = file("${path.module}/templates/init.sh")
  vars = {
    hcloud_token   = var.hcloud_token
    hcloud_network = var.hcloud_network_id

    k3s_token   = var.k3s_token
    k3s_channel = var.k3s_channel

    ccm_manifest = data.template_file.ccm_manifest.rendered
    csi_manifest = data.template_file.csi_manifest.rendered
  }
}

resource "hcloud_server" "master" {
  name        = "${var.cluster_name}-master"
  datacenter  = var.datacenter
  image       = var.image
  server_type = var.node_type
  ssh_keys    = var.ssh_keys
  user_data   = data.template_file.master_init.rendered
  keep_disk   = true
}

resource "hcloud_server_network" "master" {
  server_id = hcloud_server.master.id
  subnet_id = var.hcloud_subnet_id
}

output "master_ipv4" {
  value = hcloud_server.master.ipv4_address
}

output "master_internal_ipv4" {
  value = hcloud_server_network.master.ip
}