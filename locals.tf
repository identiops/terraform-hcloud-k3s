# Copyright 2024, identinet GmbH. All rights reserved.
# SPDX-License-Identifier: MIT

locals {
  # See https://linuxopsys.com/topics/ubuntu-automatic-updates
  base_packages = [
    "ca-certificates",
    "fail2ban",
    "jq",
    "unattended-upgrades",
  ]
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
  default_gateway = cidrhost(var.network_cidr, 1)
  security_setup  = <<-EOT
  set -eu
  # SSH
  sed -i -e 's/^#*PermitRootLogin .*/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config
  sed -i -e 's/^#*PasswordAuthentication .*/PasswordAuthentication no/g' /etc/ssh/sshd_config
  systemctl restart sshd
  # Firewall - all other ports are opened automatically by kubernetes
  ufw allow proto tcp from any to any port 22
  ufw default deny incoming
  ufw default allow outgoing
  ufw --force enable
  systemctl restart systemd-networkd.service
  EOT
  # Required open ports, see https://docs.k3s.io/installation/requirements#inbound-rules-for-k3s-server-nodeshttps://docs.k3s.io/installation/requirements#inbound-rules-for-k3s-server-nodes
  control_plane_k8s_security_setup = <<-EOT
  ufw allow proto tcp from any to any port 2379,2380,6443
  EOT
  k8s_security_setup               = <<-EOT
  ufw allow proto tcp from any to any port 10250
  # Audit log directory, if required. See https://docs.k3s.io/security/hardening-guide
  mkdir -p -m 700 /var/lib/rancher/k3s/server/logs
  sysctl --system
  EOT
  package_updates                  = <<-EOT
  killall apt-get || true
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y
  DEBIAN_FRONTEND=noninteractive apt-get install -y ${join(" ", concat(local.base_packages, var.additional_packages))}
  EOT
  k3s_url                          = <<-EOT
  export K3S_URL='https://${hcloud_server_network.gateway.ip}:6443'
  check-cluster-readiness 600 "$K3S_URL/cacerts"
  EOT
  k3s_install                      = <<-EOT
  export INSTALL_K3S_CHANNEL="${var.k3s_channel}"
  export INSTALL_K3S_VERSION="${var.k3s_version}"
  export K3S_TOKEN="${random_string.k3s_token.result}"
  wget -qO- https://get.k3s.io | \
  EOT
  common_arguments                 = <<-EOT
  --node-ip="${local.cmd_node_ip}" \
  --node-external-ip="${local.cmd_node_external_ip}" \
  --kubelet-arg 'cloud-provider=external' \
  EOT
  control_plane_arguments          = <<-EOT
  --tls-san="${hcloud_server_network.gateway.ip}" \
  --flannel-backend=none \
  --disable-network-policy \
  --cluster-cidr="${local.cluster_cidr_network}" \
  --service-cidr="${local.service_cidr_network}" \
  --disable local-storage \
  --disable-cloud-controller \
  --disable metrics-server \
  --disable traefik \
  --disable servicelb \
  ${local.common_arguments~}
  EOT
  prices                           = jsondecode(data.http.prices.response_body).pricing
  costs_gateway                    = [for server_type in local.prices.server_types : [for price in server_type.prices : { net = tonumber(price.price_monthly.net), gross = tonumber(price.price_monthly.gross) } if price.location == var.location][0] if server_type.name == var.gateway_server_type][0]
}

data "http" "prices" {
  url = "https://api.hetzner.cloud/v1/pricing"
  request_headers = {
    Accept        = "application/json"
    Authorization = "Bearer ${var.hcloud_token}"
  }
  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "Status code invalid"
    }
  }
}
