locals {
  server_base_packages = ["ca-certificates", "jq"]
  cluster_cidr_network = cidrsubnet(var.network_cidr, var.cluster_cidr_network_bits - 8, var.cluster_cidr_network_offset)
  service_cidr_network = cidrsubnet(var.network_cidr, var.service_cidr_network_bits - 8, var.service_cidr_network_offset)
  cmd_node_ip          = "$(ip -4 -j a s dev ens10 | jq '.[0].addr_info[0].local' -r)"
  cmd_node_external_ip = "$(ip -4 -j a s dev eth0 | jq '.[0].addr_info[0].local' -r),$(ip -6 -j a s dev eth0 | jq '.[0].addr_info[0].local' -r)"
  kube-apiserver-args = {
    oidc-username-claim = "email"
    oidc-groups-claim   = "groups"
    oidc-issuer-url     = var.oidc_issuer_url
    oidc-client-id      = var.oidc_client_id
  }
  k3s_install = <<-EOT
  wget -qO- https://get.k3s.io | \
  INSTALL_K3S_CHANNEL=${var.k3s_channel} \
  INSTALL_K3S_VERSION=${var.k3s_version} \
  K3S_TOKEN=${random_string.k3s_token.result~}
  EOT
  common_arguments = <<-EOT
  --node-ip=${local.cmd_node_ip} \
  --node-external-ip=${local.cmd_node_external_ip~}
  EOT
  control_plane_arguments = <<-EOT
  --flannel-backend=none \
  --disable-network-policy \
  --cluster-cidr=${local.cluster_cidr_network} \
  --service-cidr=${local.service_cidr_network} \
  --disable local-storage \
  --disable-cloud-controller \
  --disable traefik \
  --disable servicelb \
  ${local.common_arguments~}
  EOT
}
