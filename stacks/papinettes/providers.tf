provider "cloudflare" {
  email = var.cloudflare_email
  api_key = var.cloudflare_api_key
}

provider "kubernetes" {
  host = data.terraform_remote_state.marmite.outputs.kube_host
  client_certificate = data.terraform_remote_state.marmite.outputs.kube_client_cert
  client_key = data.terraform_remote_state.marmite.outputs.kube_client_key
  cluster_ca_certificate = data.terraform_remote_state.marmite.outputs.kube_ca_cert
}

provider "helm" {
  kubernetes {
    host = data.terraform_remote_state.marmite.outputs.kube_host
    client_certificate = data.terraform_remote_state.marmite.outputs.kube_client_cert
    client_key = data.terraform_remote_state.marmite.outputs.kube_client_key
    cluster_ca_certificate = data.terraform_remote_state.marmite.outputs.kube_ca_cert
  }
}

provider "kubectl" {
  host = data.terraform_remote_state.marmite.outputs.kube_host
  client_certificate = data.terraform_remote_state.marmite.outputs.kube_client_cert
  client_key = data.terraform_remote_state.marmite.outputs.kube_client_key
  cluster_ca_certificate = data.terraform_remote_state.marmite.outputs.kube_ca_cert
}
