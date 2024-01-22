resource "random_string" "k3s_token" {
  length  = 48
  upper   = false
  special = false
}
