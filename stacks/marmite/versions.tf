terraform {
  required_version = ">= 1.5.0"

  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "4.22.0"
    }
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.43.0"
    }
  }
}