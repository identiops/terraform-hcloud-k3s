# Copyright 2025, identinet GmbH. All rights reserved.
# SPDX-License-Identifier: MIT

locals {
  image2interface = {
    "ubuntu-22.04" = "ens10"
    "ubuntu-24.04" = "enp7s0"
  }
}

variable "image" {
  type        = string
  description = "Image name"
}

variable "any" {
  type        = any
  description = "Any additional information"
}

output "network_interface" {
  value       = local.image2interface[var.image]
  description = "Network interface name that corresponds to image"
}

output "image" {
  value       = var.image
  description = "Image name"
}


output "any" {
  value       = var.any
  description = "Any additional information passed in"
}
