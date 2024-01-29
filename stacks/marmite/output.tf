output "kubeconfig" {
  value = module.marmite.kubeconfig
  sensitive = true
}

output "kubeconfig_filename" {
  value = module.marmite.kubeconfig_filename
  sensitive = true
}

output "load_balancer_ipv4_address" {
  value = module.marmite.load_balancer_ipv4_address
}