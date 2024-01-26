resource "hcloud_server" "gateway" {
  lifecycle {
    prevent_destroy = false
    ignore_changes  = [ssh_keys, user_data]
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
    packages                   = concat(["netcat-openbsd", "haproxy"], local.base_packages) # netcat is required for acting as an ssh jump jost
    # Find runcmd: find /var/lib/cloud/instances -name runcmd
    runcmd = concat([
      local.security_setup,
      "ufw allow proto tcp from any to any port 6443",
      <<-EOT
      echo 'Unattended-Upgrade::Automatic-Reboot "true";' >> /etc/apt/apt.conf.d/50unattended-upgrades
      # Enable packet forwarding
      ufw route allow in on ens10 out on eth0
      systemctl daemon-reload
      export NU_VERSION="0.89.0"
      curl -Lo /tmp/nu.tar.gz https://github.com/nushell/nushell/releases/download/$NU_VERSION/nu-$NU_VERSION-x86_64-linux-gnu-full.tar.gz
      tar xvzfC /tmp/nu.tar.gz /tmp nu-$NU_VERSION-x86_64-linux-gnu-full/nu
      mv /tmp/nu-$NU_VERSION-x86_64-linux-gnu-full/nu /usr/local/bin
      mkdir -p /etc/haproxy/haproxy.d
      echo 'EXTRAOPTS="-f /etc/haproxy/haproxy.d"' >> /etc/default/haproxy
      systemctl restart haproxy
      systemctl enable --now haproxy-k8s.timer
      EOT
    ], var.additional_runcmd)
    write_files = [
      {
        path        = "/usr/local/bin/haproxy-k8s.nu"
        content     = templatefile("${path.module}/templates/haproxy-k8s.nu", { token = var.hcloud_token })
        permissions = "0700"
      },
      {
        path    = "/etc/systemd/system/haproxy-k8s.service"
        content = file("${path.module}/templates/haproxy-k8s.service")
      },
      {
        path    = "/etc/systemd/system/haproxy-k8s.timer"
        content = file("${path.module}/templates/haproxy-k8s.timer")
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
