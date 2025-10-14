# Copyright 2024, identinet GmbH. All rights reserved.
# SPDX-License-Identifier: MIT

terraform {
  required_providers {
    # See Version Constraints: https://developer.hashicorp.com/terraform/language/expressions/version-constraints
    hcloud = {
      # Documentation; https://registry.terraform.io/providers/hetznercloud/hcloud
      source  = "hetznercloud/hcloud"
      version = "~> 1.54.0"
    }
  }
  required_version = "~> 1.0"
}

