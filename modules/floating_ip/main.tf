resource "hcloud_floating_ip" "ip" {
  count         = var.ip_count
  name          = "${var.cluster_name}-${var.ip_type}-${count.index}"
  type          = var.ip_type
  home_location = var.home_location
}

output "floating_ip" {
  value = hcloud_floating_ip.ip.*.ip_address
}
