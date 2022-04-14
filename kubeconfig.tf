resource "local_file" "setkubeconfig" {
  filename = "./setkubeconfig"
  content = templatefile(
    "${path.module}/templates/kubeconfig_setkubeconfig", {
      cluster_name = var.cluster_name
      oidc_enabled = var.oidc_enabled
      oidc_issuer_url = var.oidc_issuer_url
      oidc_client_id = var.oidc_client_id
      oidc_client_secret = var.oidc_client_secret
      master_ipv4  = hcloud_server.control_plane_master.ipv4_address
    }
  )

  file_permission = "0755"
}

resource "local_file" "unsetkubeconfig" {
  filename = "./unsetkubeconfig"
  content = templatefile(
    "${path.module}/templates/kubeconfig_unsetkubeconfig", {
      cluster_name = var.cluster_name
    }
  )

  file_permission = "0755"

  provisioner "local-exec" {
    when    = destroy
    command = "./unsetkubeconfig"
  }
}
