# Copyright 2024, identinet GmbH. All rights reserved.
# SPDX-License-Identifier: MIT

resource "local_file" "ssh_config" {
  count    = var.create_scripts ? 1 : 0
  filename = "./.ssh/config"
  content = templatefile(
    "${path.module}/templates/ssh_config", {
      cluster_name = var.cluster_name
      cluster_ip   = hcloud_server.gateway.ipv4_address
      control_plane_init_ip = [for pool in module.node_pool_cluster_init :
      [for node in pool.nodes : node.private[0]][0]][0]
      node_pools = merge(module.node_pool_cluster_init, module.node_pools)
      cwd        = path.cwd
    }
  )
  file_permission = "0600"
}

resource "local_file" "scp-node" {
  count    = var.create_scripts ? 1 : 0
  filename = "./scp-node"
  content = templatefile(
    "${path.module}/templates/scp-node", {
      cwd = path.cwd
    }
  )
  file_permission = "0755"
}

resource "local_file" "ssh-node" {
  count    = var.create_scripts ? 1 : 0
  filename = "./ssh-node"
  content = templatefile(
    "${path.module}/templates/ssh-node", {
      cwd = path.cwd
    }
  )
  file_permission = "0755"
}

resource "local_file" "ls-nodes" {
  count    = var.create_scripts ? 1 : 0
  filename = "./ls-nodes"
  content = templatefile(
    "${path.module}/templates/ls-nodes", {
      cwd = path.cwd
    }
  )
  file_permission = "0755"
}

resource "local_file" "setkubeconfig" {
  count    = var.create_scripts ? 1 : 0
  filename = "./setkubeconfig"
  content = templatefile(
    "${path.module}/templates/kubeconfig_setkubeconfig", {
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
