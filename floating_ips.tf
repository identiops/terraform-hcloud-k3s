module "floating_ip" {
  source = "./modules/floating_ip"

  cluster_name  = var.cluster_name
  home_location = substr(var.datacenter, 0, 4)

  for_each = var.floating_ips
  ip_type  = each.key
  ip_count = each.value
}
