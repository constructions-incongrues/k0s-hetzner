terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "4.22.0"
    }
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.44.1"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.12.1"
    }
    kubectl = {
      source = "alekc/kubectl"
      version = "2.0.4"
    }
    kustomization = {
      source = "kbst/kustomization"
      version = "0.9.5"
    }
  }
}
