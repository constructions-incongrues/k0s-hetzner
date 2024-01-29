output "kubeconfig" {
  value = k0sctl_config.cluster.kube_yaml
  sensitive = true
}

output "ca_cert" {
  value = k0sctl_config.cluster.ca_cert
}

output "client_cert" {
  value = k0sctl_config.cluster.client_cert
}

output "client_key" {
  value = k0sctl_config.cluster.private_key
  sensitive = true
}

output "kube_host" {
  value = k0sctl_config.cluster.kube_host
}