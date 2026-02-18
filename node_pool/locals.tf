locals {
  user_data_list = [for count_index in range(var.node_count):
    format("%s\n%s\n%s", "#cloud-config", yamlencode({
    # Documentation: https://cloudinit.readthedocs.io/en/latest/reference
    # not sure if these settings are required here, now that the software installation is done later
    # network = {
    #   version = 1
    #   config = [
    #     {
    #       type = "physical"
    #       name = var.network_intreface
    #       subnets = [
    #         { type    = "dhcp"
    #           gateway = var.default_gateway
    #           dns_nameservers = [
    #             "1.1.1.1",
    #             "1.0.0.1",
    #           ]
    #         }
    #       ]
    #     },
    #   ]
    # }
    package_update  = false
    package_upgrade = false
    runcmd          = count_index == 0 && length(var.runcmd_first) > 0 ? var.runcmd_first : var.runcmd
    write_files = concat([
      {
        path        = "/usr/local/bin/check-cluster-readiness"
        content     = file("${path.module}/../templates/check-cluster-readiness")
        permissions = "0755"
      },
      {
        path = "/etc/systemd/network/default-route.network"
        content = templatefile("${path.module}/../templates/default-route.network",
          {
            default_gateway   = var.default_gateway
            network_interface = var.network_interface
        })
      },
      {
        path        = "/etc/rancher/k3s/registries.yaml"
        content     = yamlencode(var.registries)
        permissions = "0600"
      },
      {
        path    = "/etc/sysctl.d/90-kubelet.conf"
        content = file("${path.module}/../templates/90-kubelet.conf")
      },
      {
        path        = "/etc/sysctl.d/98-settings.conf"
        content     = join("\n", formatlist("%s=%s", keys(var.sysctl_settings), values(var.sysctl_settings)))
        permissions = "0644"
      },
      {
        path = "/usr/local/bin/haproxy-k8s.nu"
        content = templatefile("${path.module}/../templates/haproxy-k8s.nu", {
          token = var.hcloud_token_read_only
          host  = var.k8s_ha_host
          port  = var.k8s_ha_port
        })
        permissions = "0700"
      },
      {
        path    = "/etc/systemd/system/haproxy-k8s.service"
        content = file("${path.module}/../templates/haproxy-k8s.service")
      },
      {
        path    = "/etc/systemd/system/haproxy-k8s.timer"
        content = file("${path.module}/../templates/haproxy-k8s.timer")
      },
    ], var.k3s_custom_config_files)
    }),
    yamlencode(var.additional_cloud_init)
  )]
}
