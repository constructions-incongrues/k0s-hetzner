locals {
  key_name = "${var.name_prefix}-cluster"
}

module "ssh-keypair-generator" {
  source  = "git::https://github.com/jd4883/terraform-hashicorp-ssh-keypair-generator?ref=8e4238d1076b57de0c8cac3f26638cae536ae9e1" # v1
  key_name = local.key_name
  write_private_key_file = true
  write_public_key_file = true
}
