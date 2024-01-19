terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45.0"
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
