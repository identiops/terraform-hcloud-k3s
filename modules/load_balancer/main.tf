resource "hcloud_load_balancer" "load_balancer" {
  name               = "${var.cluster_name}-${var.load_balancer_type}-${var.id}"
  load_balancer_type = var.load_balancer_type
  location           = var.location
}

resource "hcloud_load_balancer_network" "load_balancer_network" {
  load_balancer_id = hcloud_load_balancer.load_balancer.id
  network_id       = var.hcloud_network.id
}

resource "hcloud_load_balancer_service" "load_balancer_service" {
  for_each         = var.service
  load_balancer_id = hcloud_load_balancer.load_balancer.id
  protocol         = each.value.protocol
  listen_port      = each.key
  destination_port = each.value.destination_port
}

resource "hcloud_load_balancer_target" "load_balancer_target" {
  for_each = var.target

  type             = "server"
  load_balancer_id = hcloud_load_balancer.load_balancer.id
  server_id        = each.value
  use_private_ip   = true

  depends_on = [
    var.hcloud_network
  ]
}

output "load_balancer_ipv4" {
  value = hcloud_load_balancer.load_balancer.ipv4
}

output "load_balancer_ipv6" {
  value = hcloud_load_balancer.load_balancer.ipv6
}

output "load_balancer_target" {
  value = hcloud_load_balancer.load_balancer.target
}

# output "load_balancer_service" {
#   value = hcloud_load_balancer.load_balancer.service
# }
