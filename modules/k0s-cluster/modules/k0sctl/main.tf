resource "k0sctl_config" "cluster" {
  metadata {
    name = var.cluster_name
  }

  spec {
    dynamic "host" {
      for_each = var.controller_nodes
      content {
        role = host.value.labels.role
        ssh {
          address = host.value.ipv4_address
          key_path = var.ssh_key_path
          port = 22
          user = "root"
        }
      }
    }

    dynamic "host" {
      for_each = var.worker_nodes
      content {
        role = host.value.labels.role
        ssh {
          address = host.value.ipv4_address
          key_path = var.ssh_key_path
          port = 22
          user = "root"
        }
        install_flags = [
          "--enable-cloud-provider",
          "--kubelet-extra-args=\"--cloud-provider=external\""
         ]
      }
    }

    k0s {
      version = var.k0s_version
      config = templatefile("${path.module}/../../templates/cluster-config.yaml.tpl", {
        controller_nodes = var.controller_nodes
        load_balancer_ipv4_address = var.load_balancer_ipv4_address
      })
    }
  }
}
