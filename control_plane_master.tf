locals {
  additional_yaml = <<-EOT
  write_files:
    - path: /run/csi/kustomization.yml
      content: |
        ${indent(6, "${file("${path.module}/templates/kustomization.yml")}")}
    - path: /run/calico.yml
      content: |
        ${indent(6, "${templatefile("${path.module}/templates/calico.yml", {
        cluster_cidr_network = local.cluster_cidr_network
      })}")}
  EOT
  additional_user_data = <<-EOT
  - |
    while ! test -d /var/lib/rancher/k3s/server/manifests; do
      echo "Waiting for '/var/lib/rancher/k3s/server/manifests'"
      sleep 1
    done
  - kubectl create -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml
  - kubectl apply -f /run/calico.yml
  - kubectl -n kube-system create secret generic hcloud --from-literal=token=${var.hcloud_token} --from-literal=network=${hcloud_network.private.id}
  - |
    if [ "${var.hcloud_ccm_driver_install}" = "true" ]; then
      wget -qO /var/lib/rancher/k3s/server/manifests/hcloud-ccm.yaml https://github.com/hetznercloud/hcloud-cloud-controller-manager/releases/download/${var.hcloud_ccm_driver_version}/ccm-networks.yaml
    fi
  - kubectl -n kube-system create secret generic hcloud-csi --from-literal=token=${var.hcloud_token}
  - |
    if [ "${var.hcloud_csi_driver_install}" = "true" ]; then
      wget -qO /run/csi/csi.yaml https://raw.githubusercontent.com/hetznercloud/csi-driver/${var.hcloud_csi_driver_version}/deploy/kubernetes/hcloud-csi.yml
      kubectl kustomize /run/csi >/var/lib/rancher/k3s/server/manifests/hcloud-csi.yaml
    fi
  EOT
}

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
    "${path.module}/templates/node_init.tftpl", {
      apt_packages = var.apt_packages

      cmd_install_k3s = <<-EOT
      - >
        wget -qO- https://get.k3s.io |
        INSTALL_K3S_CHANNEL=${var.k3s_channel}
        INSTALL_K3S_VERSION=${var.k3s_version}
        K3S_TOKEN=${random_string.k3s_token.result}
        sh -s - server
        --cluster-init
        --flannel-backend=none
        --disable-network-policy
        --cluster-cidr=${local.cluster_cidr_network}
        --service-cidr=${local.service_cidr_network}
        --node-ip=${local.cmd_node_ip}
        --node-external-ip=${local.cmd_node_external_ip}
        --disable local-storage
        --disable-cloud-controller
        --disable traefik
        --disable servicelb
        --kubelet-arg 'cloud-provider=external'
        ${var.control_plane_k3s_addtional_options}
        %{for key, value in local.kube-apiserver-args~}
--kube-apiserver-arg=${key}=${value}
        %{endfor~}
      EOT

      # Concatenate the required yaml with user provided ones
      additional_yaml = <<-EOT
      ${local.additional_yaml}
      ${var.additional_yaml}
      EOT

      # Concatenate the required commands with user provided ones
      additional_user_data = <<-EOT
      ${local.additional_user_data}
      ${var.control_plane_master_user_data}
      EOT
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
