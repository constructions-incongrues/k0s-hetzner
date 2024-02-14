output "kubeconfig" {
  value     = module.kube-hetzner.kubeconfig
  sensitive = true
}

output "kubernetes_api_endpoint" {
  value = module.kube-hetzner.control_planes_public_ipv4
}