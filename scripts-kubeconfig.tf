resource "local_file" "setkubeconfig" {
  count    = var.create_scripts ? 1 : 0
  filename = "./setkubeconfig"
  content = templatefile(
    "${path.module}/templates/kubeconfig_setkubeconfig", {
      # cluster_ip         = var.enable_load_balancer ? hcloud_load_balancer.control_plane_load_balancer[0].ipv4 : (var.enable_public_net_ipv4 ? hcloud_server.control_plane_main.ipv4_address : "[${hcloud_server.control_plane_main.ipv6_address}]")
      cluster_name       = var.cluster_name
      cluster_ip         = hcloud_server.gateway.ipv4_address
      oidc_enabled       = var.oidc_enabled
      oidc_issuer_url    = var.oidc_issuer_url
      oidc_client_id     = var.oidc_client_id
      oidc_client_secret = var.oidc_client_secret
      cwd                = path.cwd
    }
  )
  file_permission = "0755"
}

resource "local_file" "unsetkubeconfig" {
  count    = var.create_scripts ? 1 : 0
  filename = "./unsetkubeconfig"
  content = templatefile(
    "${path.module}/templates/kubeconfig_unsetkubeconfig", {
      cluster_name = var.cluster_name
      cwd          = path.cwd
    }
  )
  file_permission = "0755"
  provisioner "local-exec" {
    when    = destroy
    command = "./unsetkubeconfig"
  }
}
