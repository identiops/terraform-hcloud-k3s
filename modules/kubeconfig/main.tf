resource "local_file" "setkubeconfig" {
    filename = "./setkubeconfig"
    content  = templatefile(
      "${path.module}/templates/setkubeconfig", {
        cluster_name = var.cluster_name
        master_ipv4 = var.master_ipv4
      }
    )

    file_permission = "0755"
}

resource "local_file" "unsetkubeconfig" {
    filename = "./unsetkubeconfig"
    content  = templatefile(
      "${path.module}/templates/unsetkubeconfig", {
        cluster_name = var.cluster_name
      }
    )

    file_permission = "0755"

    provisioner "local-exec" {
        when    = destroy
        command = "./unsetkubeconfig"
    }
}
