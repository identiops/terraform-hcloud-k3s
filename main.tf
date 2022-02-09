provider "hcloud" {
  token = var.hcloud_token
}

resource "random_string" "k3s_token" {
  length  = 48
  upper   = false
  special = false
}
