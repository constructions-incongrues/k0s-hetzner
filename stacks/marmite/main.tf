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

# Hetzner Cloud Cloud Controller Manager
resource "kubernetes_secret" "hcloud" {
  metadata {
    name = "hcloud"
    namespace = "kube-system"
  }

  data = {
    network = "marmite-network"
    token = var.hcloud_api_token
  }
}

resource "helm_release" "hcloud-ccm" {
  chart = "hcloud-cloud-controller-manager"
  version = "v1.19.0"
  name = "hcloud-cloud-controller-manager"
  repository = "https://charts.hetzner.cloud"
  wait = true
  wait_for_jobs = true
  namespace = "kube-system"

  set {
    name = "networking.enabled"
    value = true
  }

  depends_on = [ module.marmite ]
}

# Hetzner Cloud Common Storage Interface
resource "helm_release" "hcloud-csi" {
  chart = "hcloud-csi"
  version = "v2.6.0"
  name = "hcloud-csi"
  repository = "https://charts.hetzner.cloud"
  namespace = "kube-system"

  wait = true
  wait_for_jobs = true

  set {
    name = "node.kubeletDir"
    value = "/var/lib/k0s/kubelet"
  }
  set {
    name = "node.hostNetwork"
    value = true
  }

  depends_on = [ module.marmite ]
}

# Ingress Controller
module "nginx-controller" {
  source  = "git::https://github.com/terraform-iaac/terraform-helm-nginx-controller?ref=40d483dd4396ea3c2f7a9cc7d8428f35b1ba7930" # 2.3.0
  ip_address = module.marmite.load_balancer_ipv4_address
  additional_set = [{
    name = "controller.service.annotations.load-balancer\\.hetzner\\.cloud/name"
    value = "marmite-load-balancer"
  }, {
    name = "controller.service.annotations.load-balancer\\.hetzner\\.cloud/disable-private-ingress"
    value : true
  }, {
    name = "controller.service.annotations.load-balancer\\.hetzner\\.cloud/ipv6-disabled"
    value : true
  }]

  depends_on = [ helm_release.hcloud-ccm, helm_release.hcloud-csi ]
}

# Cert Manager
module "cert-manager" {
  source  = "git::https://github.com/terraform-iaac/terraform-kubernetes-cert-manager?ref=33a94488f30f1f41cdac49ca89647279fac5edc2" # 2.6.2
  depends_on = [ helm_release.hcloud-ccm, helm_release.hcloud-csi ]
  
  cluster_issuer_email = var.certmanager_email
  cluster_issuer_create = false
}

# External DNS
module "external-dns" {
  source  = "git::https://github.com/terraform-iaac/terraform-kubernetes-external-dns?ref=b7f150aba658ed3c1798ee75149451ac3bfdc3fc" # "1.3.2"
  dns_provider = "cloudflare"
  image_tag = "0.14.0-debian-11-r4"
  additional_args = [
    "--cloudflare-proxied"
  ]
  dns = [
    "constructions-incongrues.net",
    "incongru.org",
    "interzone.network",
    "pastis-hosting.net"
  ]
  env = [{
    name = "CF_API_EMAIL"
    value = var.cloudflare_email
  }, {
    name = "CF_API_KEY"
    value = var.cloudflare_api_key
  }]

  depends_on = [ helm_release.hcloud-ccm, helm_release.hcloud-csi ]
}

# Prometheus
resource "helm_release" "prometheus-stack" {
  chart = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  version = "55.8.1"
  name = "prometheus-stack"
  namespace = "prometheus"
  create_namespace = true

  depends_on = [ helm_release.hcloud-ccm, helm_release.hcloud-csi ]
}
