provider "hcloud" {
  token = var.hcloud_api_token
}

provider "cloudflare" {
  api_key = var.cloudflare_api_key
  email = var.cloudflare_email
}