locals {
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
}
