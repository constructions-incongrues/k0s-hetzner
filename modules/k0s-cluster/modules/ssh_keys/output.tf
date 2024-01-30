output "name" {
  value = hcloud_ssh_key.this.name
}

output "public_key" {
  value = module.ssh-keypair-generator.public_key
}

output "private_key" {
  value = module.ssh-keypair-generator.private_key
  sensitive = true
}