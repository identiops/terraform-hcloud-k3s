# Copyright 2024, identinet GmbH. All rights reserved.
# SPDX-License-Identifier: MIT

resource "hcloud_ssh_key" "pub_keys" {
  for_each   = var.ssh_keys
  name       = "${var.cluster_name}-${each.key}"
  public_key = each.value
}
