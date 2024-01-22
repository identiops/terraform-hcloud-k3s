terraform {
  required_providers {
    hcloud = {
      # Documentation; https://registry.terraform.io/providers/hetznercloud/hcloud
      source  = "hetznercloud/hcloud"
      version = "1.45.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.4.1"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.4.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
    template = {
      source  = "hashicorp/template"
      version = ">= 2.2.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.10.0"
    }
  }
  required_version = ">= 1.0"
}

provider "hcloud" {
  token = var.hcloud_token
}
