variable "hcloud_token" {
  sensitive = true
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
  source       = "github.com/laurigates/terraform-hcloud-k3s"
  hcloud_token = var.hcloud_token
  ssh_keys     = [hcloud_ssh_key.default.id]
  control_plane_firewall_ids = [hcloud_firewall.base.id, hcloud_firewall.k3s-server.id]
  node_firewall_ids          = [hcloud_firewall.base.id]
  node_group_firewall_ids    = [hcloud_firewall.base.id]

  control_plane_server_type = "cx21"

  nodes = {
    "node1" = {
      server_type = "cx21"
      ip_index = 0
    }
    "node2" = {
      server_type = "cx21"
      ip_index = 1
    }
  }
}

resource "hcloud_firewall" "base" {
  name = "base"
  rule {
    direction  = "in"
    protocol   = "icmp"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
}

resource "hcloud_firewall" "k3s-server" {
  name = "k3s-server"
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "6443"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
}

output "control_plane_master_ipv4" {
  depends_on  = [module.cluster]
  description = "Public IP Address of the master node"
  value       = module.cluster.control_plane_master_ipv4
}

output "nodes_ipv4" {
  depends_on  = [module.cluster]
  description = "Public IP Address of the worker nodes"
  value       = module.cluster.new_nodes_ipv4
}
