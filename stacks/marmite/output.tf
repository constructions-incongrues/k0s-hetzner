output "kubeconfig" {
  value = module.marmite.kubeconfig
  sensitive = true
}

output "kube_ca_cert" {
  value = module.marmite.ca_cert
}

output "kube_client_cert" {
  value = module.marmite.client_cert
}

output "kube_client_key" {
  value = module.marmite.client_key
  sensitive = true
}

output "kube_host" {
  value = module.marmite.host
}

output "load_balancer_ipv4_address" {
  value = module.marmite.load_balancer_ipv4_address
}

output "ssh_private_key" {
  value = module.marmite.ssh_private_key
  sensitive = true
}