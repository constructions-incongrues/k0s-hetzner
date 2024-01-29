output "kubeconfig" {
  value = local_sensitive_file.kubeconfig.content
  sensitive = true
}

output "kubeconfig_filename" {
  value = abspath(local_sensitive_file.kubeconfig.filename)
}

output "load_balancer_ipv4_address" {
  value = module.load_balancer.ipv4_address
}
