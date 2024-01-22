resource "hcloud_server" "control_plane_main" {
  lifecycle {
    prevent_destroy = false
    ignore_changes  = [user_data, image]
  }
  depends_on = [time_sleep.wait_30_seconds]

  name               = "${var.cluster_name}-control-plane-main"
  delete_protection  = var.delete_protection
  rebuild_protection = var.delete_protection
  location           = var.location
  image              = var.image
  server_type        = var.control_plane_main_server_type
  ssh_keys           = [for k in hcloud_ssh_key.pub_keys : k.name]
  labels             = var.control_plane_main_labels
  user_data          = local.control_plane_main_user_data
  firewall_ids       = var.control_plane_firewall_ids

  public_net {
    ipv4_enabled = var.enable_public_net_ipv4
    ipv6_enabled = var.enable_public_net_ipv6
  }

  # Network needs to be present twice for some unknown reason :-/
  network {
    network_id = hcloud_network.private.id
    ip         = cidrhost(hcloud_network_subnet.subnet.ip_range, 2)
  }
}

resource "hcloud_server_network" "control_plane_main" {
  server_id  = hcloud_server.control_plane_main.id
  network_id = hcloud_network.private.id
  ip         = cidrhost(hcloud_network_subnet.subnet.ip_range, 2)
}

resource "time_sleep" "wait_30_seconds" {
  depends_on      = [hcloud_server.gateway]
  create_duration = "30s"
}

locals {
  control_plane_main_user_data = format("%s\n%s\n%s", "#cloud-config", yamlencode({
    # not sure if I need these settings now that the software installation is done later
    network = {
      version = 1
      config = [
        {
          type = "physical"
          name = "ens10"
          subnets = [
            { type    = "dhcp"
              gateway = "10.0.0.1"
              dns_nameservers = [
                "1.1.1.1",
                "1.0.0.1",
              ]
            }
          ]
        },
      ]
    }
    package_update  = false
    package_upgrade = false
    # packages        = concat(local.base_packages, var.additional_packages) # netcat is required for acting as an ssh jump jost
    runcmd = concat([
      local.security_setup,
      local.k8s_security_setup,
      local.package_updates,
      <<-EOT
      ${local.k3s_install~}
      sh -s - server \
      --cluster-init \
      ${local.control_plane_arguments~}
      ${!var.control_plane_main_schedule_workloads ? "--node-taint CriticalAddonsOnly=true:NoExecute" : ""} \
      ${var.control_plane_k3s_additional_options} %{for key, value in var.control_plane_main_labels} --node-label=${key}=${value} %{endfor} %{for key, value in local.kube-apiserver-args} --kube-apiserver-arg=${key}=${value} %{endfor}


      EOT
      ,
      <<-EOT
      while ! test -d /var/lib/rancher/k3s/server/manifests; do
        echo "Waiting for '/var/lib/rancher/k3s/server/manifests'"
        sleep 1
      done
      EOT
      ,
      "CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)",
      "CLI_ARCH=amd64",
      "curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/$CILIUM_CLI_VERSION/cilium-linux-$CLI_ARCH.tar.gz{,.sha256sum}",
      "sha256sum --check cilium-linux-$CLI_ARCH.tar.gz.sha256sum",
      "tar xzvfC cilium-linux-$CLI_ARCH.tar.gz /usr/local/bin",
      "rm cilium-linux-$CLI_ARCH.tar.gz{,.sha256sum}",
      "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml",
      "cilium install --version '${var.cilium_version}' --set-string routingMode=native,ipv4NativeRoutingCIDR=${var.network_cidr},ipam.operator.clusterPoolIPv4PodCIDRList=${local.cluster_cidr_network},k8sServiceHost=${local.cmd_node_ip}",
      # "rm /usr/local/bin/cilium",
      "kubectl -n kube-system create secret generic hcloud --from-literal='token=${var.hcloud_token}' --from-literal='network=${hcloud_network.private.id}'",
      <<-EOT
      if [ "${var.hcloud_ccm_driver_install}" = "true" ]; then
        wget -qO /var/lib/rancher/k3s/server/manifests/hcloud-ccm.yaml "https://github.com/hetznercloud/hcloud-cloud-controller-manager/releases/download/${var.hcloud_ccm_driver_version}/ccm-networks.yaml"
      fi
      EOT
      ,
      <<-EOT
      if [ "${var.hcloud_csi_driver_install}" = "true" ]; then
        wget -qO /run/csi/csi.yaml "https://raw.githubusercontent.com/hetznercloud/csi-driver/${var.hcloud_csi_driver_version}/deploy/kubernetes/hcloud-csi.yml"
        kubectl kustomize /run/csi >/var/lib/rancher/k3s/server/manifests/hcloud-csi.yaml
      fi
      EOT
      ,
      "curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash -",
      "helm repo add kubereboot https://kubereboot.github.io/charts",
      "helm install -n kube-system kured kubereboot/kured --version '${var.kured_version}' --set 'configuration.timeZone=${var.additional_cloud_init.timezone},configuration.startTime=${var.kured_start_time},configuration.endTime=${var.kured_end_time},configuration.rebootDays=${var.kured_reboot_days}'"
      # "rm /usr/local/bin/helm",
    ], var.additional_runcmd)
    write_files = [
      {
        path    = "/run/csi/kustomization.yml"
        content = file("${path.module}/templates/kustomization.yml")
      },
      {
        path    = "/etc/systemd/network/default-route.network"
        content = file("${path.module}/templates/default-route.network")
      },
    ]
    }),
    yamlencode(var.additional_cloud_init)
  )
}

resource "local_file" "control_plane_main_user_data" {
  count           = var.create_scripts ? 1 : 0
  filename        = "./.control_plane_main_user_data.yaml"
  content         = local.control_plane_main_user_data
  file_permission = "0600"
}
