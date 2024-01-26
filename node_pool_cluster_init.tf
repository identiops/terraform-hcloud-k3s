module "node_pool_cluster_init" {
  source     = "./node_pool"
  depends_on = [time_sleep.wait_for_gateway_to_become_ready]

  # This is exactlu one node pool
  for_each               = { for k, v in var.node_pools : k => v if v.cluster_can_init }
  cluster_name           = var.cluster_name
  name                   = each.key
  location               = var.location
  delete_protection      = var.delete_protection
  node_type              = each.value.type
  node_count             = each.value.count
  node_labels            = merge(each.value.labels, each.value.is_control_plane ? { "control-plane" = "true" } : {})
  image                  = var.image
  ssh_keys               = [for k in hcloud_ssh_key.pub_keys : k.name]
  firewall_ids           = each.value.is_control_plane ? var.control_plane_firewall_ids : var.worker_node_firewall_ids
  hcloud_network_id      = hcloud_network.private.id
  enable_public_net_ipv4 = var.enable_public_net_ipv4
  enable_public_net_ipv6 = var.enable_public_net_ipv6

  runcmd_first = (each.value.cluster_init_action.init || each.value.cluster_init_action.reset) ? concat([
    local.security_setup,
    local.control_plane_k8s_security_setup,
    local.k8s_security_setup,
    local.package_updates,
    <<-EOT
      ${local.k3s_install~}
      sh -s - server \
      ${each.value.cluster_init_action.init ? "--cluster-init" : ""} \
      ${each.value.cluster_init_action.reset ? "--cluster-reset --cluster-reset-restore-path='${each.value.cluster_init_action.reset_restore_path}'" : ""} \
      ${local.control_plane_arguments~}
      ${!each.value.schedule_workloads ? "--node-taint CriticalAddonsOnly=true:NoExecute" : ""}  %{for k, v in each.value.taints} --node-taint "${k}:${v}" %{endfor}  \
      ${var.control_plane_k3s_init_additional_options} ${var.control_plane_k3s_additional_options}  %{for key, value in merge(each.value.labels, each.value.is_control_plane ? { "control-plane" = "true" } : {})} --node-label=${key}=${value} %{endfor} %{for key, value in local.kube-apiserver-args} --kube-apiserver-arg=${key}=${value} %{endfor}
      while ! test -d /var/lib/rancher/k3s/server/manifests; do
        echo "Waiting for '/var/lib/rancher/k3s/server/manifests'"
        sleep 1
      done
      CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
      CLI_ARCH=amd64
      curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/$CILIUM_CLI_VERSION/cilium-linux-$CLI_ARCH.tar.gz{,.sha256sum}
      sha256sum --check cilium-linux-$CLI_ARCH.tar.gz.sha256sum
      tar xzvfC cilium-linux-$CLI_ARCH.tar.gz /usr/local/bin
      rm -f cilium-linux-$CLI_ARCH.tar.gz{,.sha256sum}
      export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
      cilium install --version '${var.cilium_version}' --set-string routingMode=native,ipv4NativeRoutingCIDR=${var.network_cidr},ipam.operator.clusterPoolIPv4PodCIDRList=${local.cluster_cidr_network},k8sServiceHost=${local.cmd_node_ip}
      # rm /usr/local/bin/cilium
      kubectl -n kube-system create secret generic hcloud --from-literal='token=${var.hcloud_token}' --from-literal='network=${hcloud_network.private.id}'
      curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash -
      helm repo add hcloud https://charts.hetzner.cloud
      helm install hcloud-ccm hcloud/hcloud-cloud-controller-manager -n kube-system --version '${var.hcloud_ccm_driver_chart_version}' --set 'networking.enabled=true,networking.clusterCIDR=${local.cluster_cidr_network}'
      helm install hcloud-csi hcloud/hcloud-csi -n kube-system --version '${var.hcloud_csi_driver_chart_version}' --set 'storageClasses[0].name=hcloud-volumes,storageClasses[0].defaultStorageClass=true,storageClasses[0].retainPolicy=Retain'
      helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
      helm install -n kube-system metrics-server metrics-server/metrics-server --version '${var.metrics_server_chart_version}'
      helm repo add kubereboot https://kubereboot.github.io/charts
      helm install -n kube-system kured kubereboot/kured --version '${var.kured_chart_version}' --set 'configuration.timeZone=${var.additional_cloud_init.timezone},configuration.startTime=${var.kured_start_time},configuration.endTime=${var.kured_end_time},configuration.rebootDays={${var.kured_reboot_days}},tolerations[0].key=CriticalAddonsOnly,tolerations[0].operator=Exists'
      kubectl apply -f "https://github.com/rancher/system-upgrade-controller/releases/download/${var.system_upgrade_controller_version}/system-upgrade-controller.yaml"
      # rm /usr/local/bin/helm
      EOT
  ], var.additional_runcmd) : []
  runcmd = concat([
    local.security_setup,
    each.value.is_control_plane ? local.control_plane_k8s_security_setup : "",
    local.k8s_security_setup,
    local.package_updates,
    # Add a delay so other control plane nodes are not immediately trying to join when init or reset are triggered
    (each.value.cluster_init_action.init || each.value.cluster_init_action.reset) ? "sleep 60" : "",
    "export K3S_URL='https://${hcloud_server_network.gateway.ip}:6443'",
    each.value.is_control_plane ?
    <<-EOT
      ${local.k3s_install~}
      sh -s - server \
      ${local.control_plane_arguments~}
      ${!each.value.schedule_workloads ? "--node-taint CriticalAddonsOnly=true:NoExecute" : ""}  %{for k, v in each.value.taints} --node-taint "${k}:${v}" %{endfor}  \
      ${var.control_plane_k3s_additional_options}  %{for key, value in merge(each.value.labels, each.value.is_control_plane ? { "control-plane" = "true" } : {})} --node-label=${key}=${value} %{endfor} %{for key, value in local.kube-apiserver-args} --kube-apiserver-arg=${key}=${value} %{endfor}
      EOT
    :
    <<-EOT
      ${local.k3s_install~}
      sh -s - agent ${local.common_arguments~}
      EOT
  ], var.additional_runcmd)
  additional_cloud_init = var.additional_cloud_init
  prices                = local.prices
}

resource "time_sleep" "wait_for_gateway_to_become_ready" {
  depends_on      = [hcloud_server.gateway]
  create_duration = "30s"
}
