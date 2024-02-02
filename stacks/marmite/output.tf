output "summary" {
  value = module.k3s.summary
}

output "kubeconfig" {
  value     = module.k3s.kube_config
  sensitive = true
}

output "ssh_private_key" {
  description = "Generated SSH private key."
  value       = tls_private_key.ed25519_provisioning.private_key_openssh
  sensitive   = true
}

output "kubernetes_api_endpoint" {
  value = module.k3s.kubernetes.api_endpoint
  sensitive = true
}

output "kubernetes_client_certificate" {
  value = module.k3s.kubernetes.client_certificate
  sensitive = true
}

output "kubernetes_client_key" {
  value = module.k3s.kubernetes.client_key
  sensitive = true
}

output "kubernetes_cluster_ca_certificate" {
  value = module.k3s.kubernetes.cluster_ca_certificate
  sensitive = true
}

output "kubernetes" {
  value = module.k3s.kubernetes
  sensitive = true
}

output "kubernetes_cluster_secret" {
  value = module.k3s.kubernetes_cluster_secret
  sensitive = true
}

output "kubernetes_ready" {
  value = module.k3s.kubernetes_ready
}

output "load_balancer_ipv4_address" {
  value = hcloud_load_balancer.load_balancer.ipv4
}