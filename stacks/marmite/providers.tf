provider "cloudflare" {
  email = var.cloudflare_email
  api_key = var.cloudflare_api_key
}

provider "hcloud" {
  token = var.hcloud_api_token
}

provider "kubernetes" {
  host = module.marmite.host
  client_certificate = module.marmite.client_cert
  client_key = module.marmite.client_key
  cluster_ca_certificate = module.marmite.ca_cert
}

provider "helm" {
  kubernetes {
    host = module.marmite.host
    client_certificate = module.marmite.client_cert
    client_key = module.marmite.client_key
    cluster_ca_certificate = module.marmite.ca_cert
  }
}

provider "kubectl" {
  host = module.marmite.host
  client_certificate = module.marmite.client_cert
  client_key = module.marmite.client_key
  cluster_ca_certificate = module.marmite.ca_cert
}
