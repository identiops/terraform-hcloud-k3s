resource "hcloud_server" "control_plane_master" {
  lifecycle {
    prevent_destroy = false
    ignore_changes  = [user_data, image]
  }
  depends_on = [hcloud_network.private, hcloud_network_subnet.subnet]

  name        = "${var.cluster_name}-control-plane-master"
  datacenter  = var.datacenter
  image       = var.image
  server_type = var.control_plane_server_type
  ssh_keys    = var.ssh_keys
  labels      = var.control_plane_labels
  # Generate cloud-init configuration
  user_data = format("%s\n%s\n%s", "#cloud-config", yamlencode({
    package_update  = true
    package_upgrade = true
    packages        = concat(local.server_base_packages, var.server_additional_packages)
    runcmd = concat([
      <<-EOT
      ${local.k3s_install}
      sh -s - server \
      --cluster-init \
      ${local.control_plane_arguments} \
      ${var.control_plane_k3s_additional_options} %{for key, value in local.kube-apiserver-args~} --kube-apiserver-arg=${key}=${value} %{~endfor~}
      EOT
      ,
      <<-EOT
      while ! test -d /var/lib/rancher/k3s/server/manifests; do
        echo "Waiting for '/var/lib/rancher/k3s/server/manifests'"
        sleep 1
      done
      EOT
      ,
      "kubectl create -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml",
      "kubectl apply -f /run/calico.yml",
      "kubectl -n kube-system create secret generic hcloud --from-literal=token=${var.hcloud_token} --from-literal=network=${hcloud_network.private.id}",
      <<-EOT
      if [ "${var.hcloud_ccm_driver_install}" = "true" ]; then
        wget -qO /var/lib/rancher/k3s/server/manifests/hcloud-ccm.yaml https://github.com/hetznercloud/hcloud-cloud-controller-manager/releases/download/${var.hcloud_ccm_driver_version}/ccm-networks.yaml
      fi
      EOT
      ,
      "kubectl -n kube-system create secret generic hcloud-csi --from-literal=token=${var.hcloud_token}",
      <<-EOT
      if [ "${var.hcloud_csi_driver_install}" = "true" ]; then
        wget -qO /run/csi/csi.yaml https://raw.githubusercontent.com/hetznercloud/csi-driver/${var.hcloud_csi_driver_version}/deploy/kubernetes/hcloud-csi.yml
        kubectl kustomize /run/csi >/var/lib/rancher/k3s/server/manifests/hcloud-csi.yaml
      fi
      EOT
    ], var.additional_runcmd)
    write_files = [
      {
        path    = "/run/csi/kustomization.yml"
        content = file("${path.module}/templates/kustomization.yml")
      },
      {
        path = "/run/calico.yml"
        content = templatefile("${path.module}/templates/calico.yml", {
          cluster_cidr_network = local.cluster_cidr_network
        })
      }
    ]
    }),
    yamlencode(var.additional_cloud_init)
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
