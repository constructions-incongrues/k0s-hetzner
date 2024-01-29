# Network
module "network" {
  source      = "./modules/network"
  name_prefix = var.cluster_name
}

# SSH keys
module "ssh_keys" {
  source = "./modules/ssh_keys"
  name_prefix = var.cluster_name
}

# Provisionning of server nodes
module "node_pools" {
  for_each = tomap(var.node_pools)

  source = "./modules/node_pool"

  hcloud_api_token = var.hcloud_api_token

  spec = {
    name            = each.key
    role            = each.value.role
    image           = each.value.image
    num_nodes       = each.value.num_nodes
    cidrhost_prefix = each.value.cidrhost_prefix
    server_type     = each.value.server_type
    hcloud_api_token = var.hcloud_api_token
  }

  name_prefix     = var.cluster_name
  subnet          = module.network.subnets["infrastructure"]

  ssh_key_name    = module.ssh_keys.name
}

module "load_balancer" {
  source = "./modules/load_balancer"
}

# Cluster installation and configuration
module "k0sctl" {
  source = "./modules/k0sctl"

  cluster_name = "${var.cluster_name}-cluster"

  cluster_cidr        = module.network.cluster_cidr
  network_cidr_blocks = module.network.network_cidr_blocks
  controller_nodes    = module.node_pools["controllers"].nodes
  worker_nodes        = module.node_pools["workers"].nodes
  ssh_key_path        = module.ssh_keys.path
}

# Kubeconfig
resource "local_sensitive_file" "kubeconfig" {
  content = module.k0sctl.kubeconfig
  filename = "${path.cwd}/var/kube/${var.cluster_name}"
  file_permission = 0600
}
