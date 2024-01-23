resource "hcloud_firewall" "gateway" {
  name = "${var.cluster_name}-gateway"

  rule {
    direction = "in"
    protocol  = "icmp"
    port      = ""
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "6443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

}

resource "hcloud_server" "gateway" {
  lifecycle {
    prevent_destroy = false
    ignore_changes  = [image, location, ssh_keys, user_data]
  }
  depends_on = [hcloud_network_subnet.subnet]

  name               = "${var.cluster_name}-gateway"
  delete_protection  = var.delete_protection
  rebuild_protection = var.delete_protection
  location           = var.location
  image              = var.image
  server_type        = var.gateway_server_type
  ssh_keys           = [for k in hcloud_ssh_key.pub_keys : k.name]
  labels             = var.gateway_labels
  # Documentation https://cloudinit.readthedocs.io/en/latest/reference/modules.html#package-update-upgrade-install
  user_data = format("%s\n%s\n%s", "#cloud-config", yamlencode({
    package_update             = true
    package_upgrade            = true
    package_reboot_if_required = true
    packages                   = concat(["netcat-openbsd"], local.base_packages) # netcat is required for acting as an ssh jump jost
    # Find runcmd: find /var/lib/cloud/instances -name runcmd
    runcmd = concat([
      local.security_setup,
      <<-EOT
      echo 'Unattended-Upgrade::Automatic-Reboot "true";' >> /etc/apt/apt.conf.d/50unattended-upgrades
      # Enable packet forwarding
      ufw route allow in on ens10 out on eth0
      systemctl daemon-reload
      systemctl enable --now proxy-k8s.socket
      EOT
    ], var.additional_runcmd)
    write_files = [
      {
        path    = "/etc/systemd/system/proxy-k8s.socket"
        content = file("${path.module}/templates/proxy-k8s.socket")
      },
      {
        path = "/etc/systemd/system/proxy-k8s.service"
        content = templatefile("${path.module}/templates/proxy-k8s.service", {
          cluster_ip = "10.0.1.2" # can't be retrieved dynamically .. it would create a loop as it depends on the main server
        })
      },
      {
        path    = "/etc/systemd/network/gateway-forwarding.network"
        content = file("${path.module}/templates/gateway-forwarding.network")
      },
      {
        # Enable postrouting with ufw
        path    = "/etc/ufw/before.rules"
        content = templatefile("${path.module}/templates/gateway-ufw-before.rules", { subnet = var.subnet_cidr })
        append  = true
      },
    ]
    }),
    yamlencode(var.additional_cloud_init)
  )
  firewall_ids = concat([hcloud_firewall.gateway.id], var.gateway_firewall_ids)

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  # Network needs to be present twice for some unknown reason :-/
  network {
    network_id = hcloud_network.private.id
    ip         = cidrhost(hcloud_network_subnet.subnet.ip_range, 1)
  }
}

resource "hcloud_server_network" "gateway" {
  server_id  = hcloud_server.gateway.id
  network_id = hcloud_network.private.id
  ip         = cidrhost(hcloud_network_subnet.subnet.ip_range, 1)
}

resource "hcloud_network_route" "default" {
  network_id  = hcloud_network.private.id
  destination = "0.0.0.0/0"
  gateway     = hcloud_server_network.gateway.ip
}
