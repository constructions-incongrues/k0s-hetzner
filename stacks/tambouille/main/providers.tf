provider "cloudflare" {
  email = var.cloudflare_email
  api_key = var.cloudflare_api_key
}

provider "hcloud" {
  token = var.hcloud_api_token
}

provider "kubernetes" {
  config_path = module.marmite.kubeconfig_filename
}

provider "helm" {
  kubernetes {
    config_path = module.marmite.kubeconfig_filename
  }
}

provider "kubectl" {
  config_path = module.marmite.kubeconfig_filename
}

provider "kustomization" {
  kubeconfig_path = module.marmite.kubeconfig_filename
}