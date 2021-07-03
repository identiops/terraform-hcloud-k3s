variable "hcloud_token" {
  type = string
}

provider "hcloud" {
  token = var.hcloud_token
}

# Create a new SSH key
resource "hcloud_ssh_key" "default" {
  name       = "Terraform Example"
  public_key = file("~/.ssh/id_rsa.pub")
}

module "cluster" {
  source       = "cicdteam/k3s/hcloud"
  version      = "0.1.2"
  hcloud_token = var.hcloud_token
  ssh_keys     = [hcloud_ssh_key.default.id]

  master_type = "cx31"

  node_groups = {
    "cx41" = 3
    "cx51" = 2
  }

  floating_ips = {
    "ipv4" = 1
  }

  master_user_data = file("${path.module}/script-to-run-on-master.sh")
  node_user_data   = file("${path.module}/script-to-run-on-node.sh")
}

output "master_ipv4" {
  depends_on  = [module.cluster]
  description = "Public IP Address of the master node"
  value       = module.cluster.master_ipv4
}

output "nodes_ipv4" {
  depends_on  = [module.cluster]
  description = "Public IP Address of the worker nodes"
  value       = module.cluster.nodes_ipv4
}

output "floating_IPs" {
  depends_on  = [module.cluster]
  description = "Floating IP Addresses for ingress"
  value       = module.cluster.floating_ips
}
