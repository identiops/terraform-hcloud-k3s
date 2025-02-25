# Copyright 2024, identinet GmbH. All rights reserved.
# SPDX-License-Identifier: MIT

terraform {
  required_providers {
    # See Version Constraints: https://developer.hashicorp.com/terraform/language/expressions/version-constraints
    hcloud = {
      # Documentation; https://registry.terraform.io/providers/hetznercloud/hcloud
      source  = "hetznercloud/hcloud"
      version = "~> 1.50.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4.5"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.3"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12.1"
    }
  }
  required_version = "~> 1.0"
}

provider "hcloud" {
  token = var.hcloud_token
}
