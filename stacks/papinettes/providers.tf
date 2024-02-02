provider "cloudflare" {
  email = var.cloudflare_email
  api_key = var.cloudflare_api_key
}

provider "kubernetes" {
  host = data.terraform_remote_state.marmite.outputs.kubernetes_api_endpoint
  client_certificate = data.terraform_remote_state.marmite.outputs.kubernetes_client_certificate
  client_key = data.terraform_remote_state.marmite.outputs.kubernetes_client_key
  cluster_ca_certificate = data.terraform_remote_state.marmite.outputs.kubernetes_cluster_ca_certificate
  # insecure = true
}

provider "helm" {
  kubernetes {
    host = data.terraform_remote_state.marmite.outputs.kubernetes_api_endpoint
    client_certificate = data.terraform_remote_state.marmite.outputs.kubernetes_client_certificate
    client_key = data.terraform_remote_state.marmite.outputs.kubernetes_client_key
    cluster_ca_certificate = data.terraform_remote_state.marmite.outputs.kubernetes_cluster_ca_certificate
    # insecure = true
  }
}

provider "kubectl" {
  host = data.terraform_remote_state.marmite.outputs.kubernetes_api_endpoint
  client_certificate = data.terraform_remote_state.marmite.outputs.kubernetes_client_certificate
  client_key = data.terraform_remote_state.marmite.outputs.kubernetes_client_key
  cluster_ca_certificate = data.terraform_remote_state.marmite.outputs.kubernetes_cluster_ca_certificate
  # insecure = true
}
