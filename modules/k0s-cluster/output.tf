output "kubeconfig" {
  value = module.k0sctl.kubeconfig
  sensitive = true
}

output "load_balancer_ipv4_address" {
  value = module.load_balancer.ipv4_address
}

output "ca_cert" {
  value = module.k0sctl.ca_cert
}

output "client_cert" {
  value = module.k0sctl.client_cert
}

output "client_key" {
  value = module.k0sctl.client_key
  sensitive = true
}

output "host" {
  value = module.k0sctl.kube_host
}

output "ssh_private_key" {
  value = module.ssh_keys.private_key
}