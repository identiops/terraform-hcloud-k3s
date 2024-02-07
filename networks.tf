# Copyright 2024, identinet GmbH. All rights reserved.
# SPDX-License-Identifier: MIT

resource "hcloud_network" "private" {
  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      name,
    ]
  }

  name              = var.cluster_name
  ip_range          = var.network_cidr
  delete_protection = var.delete_protection
}

resource "hcloud_network_subnet" "subnet" {
  network_id   = hcloud_network.private.id
  type         = "cloud"
  network_zone = var.network_zone
  ip_range     = var.subnet_cidr
}
