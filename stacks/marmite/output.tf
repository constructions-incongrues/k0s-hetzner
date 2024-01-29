output "kubeconfig" {
  value = module.marmite.kubeconfig
  sensitive = true
}

output "load_balancer_ipv4_address" {
  value = module.marmite.load_balancer_ipv4_address
}