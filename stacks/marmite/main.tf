# k0s Cluster
module "marmite" {
  source = "../../modules/k0s-cluster"

  cluster_name      = "marmite"
  hcloud_api_token  = var.hcloud_api_token

  node_pools = {
    "controllers" = {
      server_type     = "cpx11"
      image           = "ubuntu-22.04"
      prefix          = "controller-0"
      num_nodes       = 1
      role            = "controller"
      cidrhost_prefix = 3
    },
    "workers" = {
      server_type     = "cpx11"
      image           = "ubuntu-22.04"
      prefix          = "worker-0"
      num_nodes       = 1
      role            = "worker"
      cidrhost_prefix = 5
    },
  }
}
