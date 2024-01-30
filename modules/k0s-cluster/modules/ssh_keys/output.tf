output "public_key" {
  value = module.ssh-keypair-generator.keypair.public_key_openssh
}

output "private_key" {
  value = module.ssh-keypair-generator.keypair.private_key_openssh
  sensitive = true
}