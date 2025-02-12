# Copyright 2024, identinet GmbH. All rights reserved.
# SPDX-License-Identifier: MIT


module "node_pool_cluster_init_network_interface" {
  source = "./network_interface"
  # This is exactlu one node pool
  for_each = { for k, v in var.node_pools : k => v if v.cluster_can_init }
  image    = each.value.image != "" ? each.value.image : var.default_image
  any      = each.value
}


module "node_pool_cluster_init" {
  source     = "./node_pool"
  depends_on = [time_sleep.wait_for_gateway_to_become_ready]

  for_each               = module.node_pool_cluster_init_network_interface
  cluster_name           = var.cluster_name
  name                   = each.key
  hcloud_token_read_only = var.hcloud_token_read_only
  location               = each.value.any.location != "" ? each.value.any.location : var.default_location
  delete_protection      = var.delete_protection
  node_type              = each.value.any.type
  node_count             = each.value.any.count
  node_count_width       = each.value.any.count_width
  node_labels            = merge(each.value.any.labels, each.value.any.is_control_plane ? { "control-plane" = "true" } : {})
  image                  = each.value.image
  network_interface      = each.value.network_interface
  ssh_keys               = [for k in hcloud_ssh_key.pub_keys : k.name]
  firewall_ids           = each.value.any.is_control_plane ? var.control_plane_firewall_ids : var.worker_node_firewall_ids
  hcloud_network_id      = hcloud_network.private.id
  enable_public_net_ipv4 = var.enable_public_net_ipv4
  enable_public_net_ipv6 = var.enable_public_net_ipv6
  default_gateway        = local.default_gateway
  is_control_plane       = each.value.any.is_control_plane
  k8s_ha_host            = local.k8s_ha_host
  k8s_ha_port            = local.k8s_ha_port

  runcmd_first = (each.value.any.cluster_init_action.init || each.value.any.cluster_init_action.reset) ? concat([
    local.security_setup,
    local.control_plane_k8s_security_setup,
    local.k8s_security_setup,
    local.package_updates,
    local.haproxy_setup,
    <<-EOT
      ${local.k3s_install~}
      sh -s - server \
      ${each.value.any.cluster_init_action.init ? "--cluster-init" : ""} \
      ${each.value.any.cluster_init_action.reset ? "--cluster-reset --cluster-reset-restore-path='${each.value.any.cluster_init_action.reset_restore_path}'" : ""} \
      ${local.control_plane_arguments~}
      ${!each.value.any.schedule_workloads ? "--node-taint CriticalAddonsOnly=true:NoExecute" : ""}  %{for k, v in each.value.any.taints} --node-taint "${k}:${v}" %{endfor}  \
      ${var.control_plane_k3s_init_additional_options} ${var.control_plane_k3s_additional_options}  %{for key, value in merge(each.value.any.labels, each.value.any.is_control_plane ? { "control-plane" = "true" } : {})} --node-label=${key}=${value} %{endfor} %{for key, value in local.kube-apiserver-args} --kube-apiserver-arg=${key}=${value} %{endfor}
      while ! test -d /var/lib/rancher/k3s/server/manifests; do
        echo "Waiting for '/var/lib/rancher/k3s/server/manifests'"
        sleep 1
      done

      ## Chart setup
      export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
      curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash -

      ## See https://github.com/hetznercloud/hcloud-cloud-controller-manager
      kubectl -n kube-system create secret generic hcloud --from-literal='token=${var.hcloud_token}' --from-literal='network=${hcloud_network.private.id}'
      helm repo add hcloud https://charts.hetzner.cloud
      helm install hcloud-ccm hcloud/hcloud-cloud-controller-manager -n kube-system --version '${var.hcloud_ccm_driver_chart_version}' --set 'networking.enabled=true,networking.clusterCIDR=${local.cluster_cidr_network},additionalTolerations[0].key=node.kubernetes.io/not-ready,additionalTolerations[0].effect=NoSchedule'

      ## See https://artifacthub.io/packages/helm/cilium/cilium
      # CILIUM_CLI_VERSION="$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)"
      # CLI_ARCH="amd64"
      # curl -L --fail --remote-name-all "https://github.com/cilium/cilium-cli/releases/download/$CILIUM_CLI_VERSION/cilium-linux-$CLI_ARCH.tar.gz"
      # curl -L --fail --remote-name-all "https://github.com/cilium/cilium-cli/releases/download/$CILIUM_CLI_VERSION/cilium-linux-$CLI_ARCH.tar.gz.sha256sum"
      # sha256sum --check "cilium-linux-$CLI_ARCH.tar.gz.sha256sum"
      # tar xzvfC "cilium-linux-$CLI_ARCH.tar.gz" /usr/local/bin
      # rm -f "cilium-linux-$CLI_ARCH.tar.gz" "cilium-linux-$CLI_ARCH.tar.gz.sha256sum"
      # cilium install --version '${var.cilium_version}' --set "routingMode=native,ipv4NativeRoutingCIDR=${var.network_cidr},ipam.operator.clusterPoolIPv4PodCIDRList=${local.cluster_cidr_network},k8sServiceHost=${local.k8s_ha_host},k8sServicePort=${local.k8s_ha_port}"
      # rm /usr/local/bin/cilium
      helm repo add cilium https://helm.cilium.io/
      helm install cilium cilium/cilium -n kube-system --version '${var.cilium_version}' --set "routingMode=native,ipv4NativeRoutingCIDR=${var.network_cidr},ipam.operator.clusterPoolIPv4PodCIDRList=${local.cluster_cidr_network},k8sServiceHost=${local.k8s_ha_host},k8sServicePort=${local.k8s_ha_port},operator.replicas=2"

      ## See https://github.com/hetznercloud/csi-driver
      helm install hcloud-csi hcloud/hcloud-csi -n kube-system --version '${var.hcloud_csi_driver_chart_version}' --set 'storageClasses[0].name=hcloud-volumes,storageClasses[0].defaultStorageClass=true,storageClasses[0].retainPolicy=Retain'

      ## See https://artifacthub.io/packages/helm/metrics-server/metrics-server
      helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
      helm install -n kube-system metrics-server metrics-server/metrics-server --version '${var.metrics_server_chart_version}'

      ## See https://artifacthub.io/packages/helm/kured/kured
      helm repo add kubereboot https://kubereboot.github.io/charts
      helm install -n kube-system kured kubereboot/kured --version '${var.kured_chart_version}' --set 'configuration.timeZone=${var.additional_cloud_init.timezone},configuration.startTime=${var.kured_start_time},configuration.endTime=${var.kured_end_time},configuration.rebootDays={${var.kured_reboot_days}},tolerations[0].key=CriticalAddonsOnly,tolerations[0].operator=Exists'

      ## See https://github.com/rancher/charts/tree/release-v2.8/charts/system-upgrade-controller and https://github.com/rancher/system-upgrade-controller
      helm repo add rancher https://charts.rancher.io
      helm install --create-namespace -n cattle-system system-upgrade-controller rancher/system-upgrade-controller --version '${var.system_upgrade_controller_version}' --set 'systemUpgradeJobTTLSecondsAfterFinish=86400'
      # rm /usr/local/bin/helm
      EOT
    ,
    local.dist_upgrade,
  ], var.additional_runcmd) : []
  runcmd = concat([
    local.security_setup,
    each.value.any.is_control_plane ? local.control_plane_k8s_security_setup : "",
    local.k8s_security_setup,
    local.package_updates,
    local.haproxy_setup,
    local.k3s_url,
    each.value.any.is_control_plane ?
    <<-EOT
      ${local.k3s_install~}
      sh -s - server \
      ${local.control_plane_arguments~}
      --node-ip="$(ip -4 -j a s dev ${each.value.network_interface} | jq '.[0].addr_info[0].local' -r)" \
      ${!each.value.any.schedule_workloads ? "--node-taint CriticalAddonsOnly=true:NoExecute" : ""}  %{for k, v in each.value.any.taints} --node-taint "${k}:${v}" %{endfor}  \
      ${var.control_plane_k3s_additional_options}  %{for key, value in merge(each.value.any.labels, each.value.any.is_control_plane ? { "control-plane" = "true" } : {})} --node-label=${key}=${value} %{endfor} %{for key, value in local.kube-apiserver-args} --kube-apiserver-arg=${key}=${value} %{endfor}
      EOT
    :
    <<-EOT
      ${local.k3s_install~}
      sh -s - agent --node-ip="$(ip -4 -j a s dev ${each.value.network_interface} | jq '.[0].addr_info[0].local' -r)" ${local.common_arguments~}
      EOT
    ,
    local.dist_upgrade,
  ], var.additional_runcmd)
  additional_cloud_init = var.additional_cloud_init
  prices                = local.prices
}

resource "time_sleep" "wait_for_gateway_to_become_ready" {
  depends_on      = [hcloud_server.gateway]
  create_duration = "30s"
}
