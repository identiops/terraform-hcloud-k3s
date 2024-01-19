locals {
  # See https://linuxopsys.com/topics/ubuntu-automatic-updates
  base_packages        = ["ca-certificates", "jq", "fail2ban", "unattended-upgrades"]
  cluster_cidr_network = cidrsubnet(var.network_cidr, var.cluster_cidr_network_bits - 8, var.cluster_cidr_network_offset)
  service_cidr_network = cidrsubnet(var.network_cidr, var.service_cidr_network_bits - 8, var.service_cidr_network_offset)
  cmd_node_ip          = "$(ip -4 -j a s dev ens10 | jq '.[0].addr_info[0].local' -r)"
  # cmd_node_external_ip = "$(ip -4 -j a s dev eth0 | jq '.[0].addr_info[0].local' -r),$(ip -6 -j a s dev eth0 | jq '.[0].addr_info[0].local' -r)"
  cmd_node_external_ip = hcloud_server.gateway.ipv4_address
  kube-apiserver-args = var.oidc_enabled ? {
    oidc-username-claim = "email"
    oidc-groups-claim   = "groups"
    oidc-issuer-url     = var.oidc_issuer_url
    oidc-client-id      = var.oidc_client_id
  } : {}
  security_setup          = <<-EOT
  # SSH
  sed -i -e 's/^#*PermitRootLogin .*/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config
  sed -i -e 's/^#*PasswordAuthentication .*/PasswordAuthentication no/g' /etc/ssh/sshd_config
  systemctl restart sshd
  # Firewall - all other ports are opened automatically by kubernetes
  ufw allow proto tcp from any to any port 22,6443
  ufw allow proto tcp from ${var.subnet_cidr} to any port 2379,2380,10250
  ufw default deny incoming
  ufw default allow outgoing
  ufw --force enable
  systemctl restart systemd-networkd.service
  EOT
  k3s_install             = <<-EOT
  export INSTALL_K3S_CHANNEL="${var.k3s_channel}"
  export INSTALL_K3S_VERSION="${var.k3s_version}"
  export K3S_TOKEN="${random_string.k3s_token.result}"
  wget -qO- https://get.k3s.io | \
  EOT
  common_arguments        = <<-EOT
  --node-ip="${local.cmd_node_ip}" \
  --node-external-ip="${local.cmd_node_external_ip}" \
  --kubelet-arg 'cloud-provider=external' \
  EOT
  control_plane_arguments = <<-EOT
  --flannel-backend=none \
  --disable-network-policy \
  --cluster-cidr="${local.cluster_cidr_network}" \
  --service-cidr="${local.service_cidr_network}" \
  --disable local-storage \
  --disable-cloud-controller \
  --disable traefik \
  --disable servicelb \
  ${local.common_arguments~}
  EOT
}
