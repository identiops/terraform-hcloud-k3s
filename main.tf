# Copyright 2024, identinet GmbH. All rights reserved.
# SPDX-License-Identifier: MIT

resource "random_string" "k3s_token" {
  length  = 48
  upper   = false
  special = false
}
