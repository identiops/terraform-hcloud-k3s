# Copyright 2024, identinet GmbH. All rights reserved.
# SPDX-License-Identifier: MIT

locals {
  # See https://linuxopsys.com/topics/ubuntu-automatic-updates
  base_packages = [
    "ca-certificates",
    "fail2ban",
    "haproxy",
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
  haproxy_setup   = <<-EOT
  export NU_VERSION="${var.nu_version}"
  curl -Lo /tmp/nu.tar.gz "https://github.com/nushell/nushell/releases/download/$NU_VERSION/nu-$NU_VERSION-x86_64-linux-gnu-full.tar.gz"
  tar xvzfC /tmp/nu.tar.gz /tmp "nu-$NU_VERSION-x86_64-linux-gnu-full/nu"
  mv "/tmp/nu-$NU_VERSION-x86_64-linux-gnu-full/nu" /usr/local/bin
  mkdir -p /etc/haproxy/haproxy.d
  echo 'EXTRAOPTS="-f /etc/haproxy/haproxy.d"' >> /etc/default/haproxy
  systemctl restart haproxy
  systemctl enable --now haproxy-k8s.timer
  systemctl start haproxy-k8s
  EOT
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
  # Required open ports, see https://kubernetes.io/docs/reference/networking/ports-and-protocols/
  control_plane_k8s_security_setup = <<-EOT
  ufw allow proto tcp from any to any port 2379:2380,6443,10257,10259
  EOT
  k8s_security_setup               = <<-EOT
  ufw allow proto tcp from any to any port 10250
  ufw allow proto tcp from any to any port 30000:32767
  # Audit log directory, if required. See https://docs.k3s.io/security/hardening-guide
  mkdir -p -m 700 /var/lib/rancher/k3s/server/logs
  sysctl --system
  EOT
  package_updates                  = <<-EOT
  killall apt-get || true
  apt-get update
  # DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y
  DEBIAN_FRONTEND=noninteractive apt-get install -y ${join(" ", concat(local.base_packages, var.additional_packages))}
  EOT
  k8s_ha_host                      = "127.0.0.1"
  k8s_ha_port                      = 16443
  k3s_url                          = <<-EOT
  export K3S_URL='https://${local.k8s_ha_host}:${local.k8s_ha_port}'
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
  --disable-cloud-controller \
  --egress-selector-mode disabled \
  --cluster-cidr="${local.cluster_cidr_network}" \
  --service-cidr="${local.service_cidr_network}" \
  --disable local-storage \
  --disable metrics-server \
  --disable servicelb \
  --disable traefik \
  ${local.common_arguments~}
  EOT
  prices                           = jsondecode(data.http.prices.response_body).pricing
  costs_gateway                    = [for server_type in local.prices.server_types : [for price in server_type.prices : { net = tonumber(price.price_monthly.net), gross = tonumber(price.price_monthly.gross) } if price.location == var.default_location][0] if server_type.name == var.gateway_server_type][0]
}

data "http" "prices" {
  url = "https://api.hetzner.cloud/v1/pricing"
  request_headers = {
    Accept        = "application/json"
    Authorization = "Bearer ${var.hcloud_token_read_only}"
  }
  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "Status code invalid"
    }
  }
}
