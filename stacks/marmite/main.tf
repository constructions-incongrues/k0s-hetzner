# k0s Cluster
module "marmite" {
  source = "../../modules/k0s-cluster"

  cluster_name      = "marmite"
  hcloud_api_token  = var.hcloud_api_token

  node_pools = {
    "controllers" = {
      server_type     = var.controllers_server_type
      image           = "ubuntu-22.04"
      prefix          = "controller-0"
      num_nodes       = var.controllers_count
      role            = "controller"
      cidrhost_prefix = 3
    },
    "workers" = {
      server_type     = var.workers_server_type
      image           = "ubuntu-22.04"
      prefix          = "worker-0"
      num_nodes       = var.workers_count
      role            = "worker"
      cidrhost_prefix = 5
    },
  }
}
