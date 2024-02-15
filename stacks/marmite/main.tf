resource "tls_private_key" "ed25519_provisioning" {
  algorithm = "ED25519"
}

# R2 bucket backup location
resource "cloudflare_r2_bucket" "tambouille" {
  account_id = var.cloudflare_r2_account_id
  name = "tambouille"
}

module "kube-hetzner" {
  source = "kube-hetzner/kube-hetzner/hcloud"
  version = "2.11.8"

  providers = {
    hcloud = hcloud
  }

  hcloud_token = var.hcloud_api_token
  enable_cert_manager = true
  enable_longhorn = false
  enable_metrics_server = false
  enable_klipper_metal_lb = false
  allow_scheduling_on_control_plane = false
  disable_hetzner_csi = false
  enable_rancher = false
  ingress_controller = "traefik"
  traefik_redirect_to_https = false
  load_balancer_disable_ipv6 = true
  
  additional_k3s_environment = {
    INSTALL_K3S_SKIP_SELINUX_RPM = true
  }
  control_planes_custom_config = {
    selinux = false
  }

  extra_kustomize_parameters = {
    cloudflare_api_key = var.cloudflare_api_key
    cloudflare_email = var.cloudflare_email
    cloudflare_proxied = var.cloudflare_proxied
    objectstorage_access_key_id = var.objectstorage_access_key_id
    objectstorage_access_key_secret = var.objectstorage_access_key_secret
    objectstorage_endpoint = var.objectstorage_endpoint
    objectstorage_bucket = var.objectstorage_bucket
    juicefs_kdrive_accesskey = var.juicefs_kdrive_accesskey
    juicefs_kdrive_bucket = var.juicefs_kdrive_bucket
    juicefs_kdrive_secretkey = var.juicefs_kdrive_secretkey
  }

  ssh_public_key = tls_private_key.ed25519_provisioning.public_key_openssh
  ssh_private_key = tls_private_key.ed25519_provisioning.private_key_openssh
  ssh_additional_public_keys = []

  network_region = "eu-central"
  firewall_kube_api_source = ["0.0.0.0/0"]
  
  # The default is "true" (in HA setup i.e. at least 3 control plane nodes & 2 agents, just keep it enabled since it works flawlessly).
  automatically_upgrade_k3s = (var.nodepool_servers.count >= 3 && var.nodepool_agents_workers.count + var.nodepool_agents_storage.count >=2)

  # The default is "true" (in HA setup it works wonderfully well, with automatic roll-back to the previous snapshot in case of an issue).
  # IMPORTANT! For non-HA clusters i.e. when the number of control-plane nodes is < 3, you have to turn it off.
  automatically_upgrade_os = (var.nodepool_servers.count >= 3)

  control_plane_nodepools = [
    {
      name        = "server",
      server_type = var.nodepool_servers.type,
      location    = var.nodepool_servers.location,
      labels      = [],
      taints      = [],
      count       = var.nodepool_servers.count
    }
  ]

  agent_nodepools = [
    {
      name        = "worker",
      server_type = var.nodepool_agents_workers.type,
      location    = var.nodepool_agents_workers.location,
      labels      = [],
      taints      = [],
      count       = var.nodepool_agents_workers.count
    },
    {
      name        = "storage",
      server_type = var.nodepool_agents_storage.type,
      location    = var.nodepool_agents_storage.location,
      labels      = [
        "node.kubernetes.io/server-usage=storage"
      ],
      labels = []
      taints = []
      count       = var.nodepool_agents_storage.count,
      longhorn_volume_size = var.nodepool_agents_storage.longhorn_volume_size
    }
  ]

  # * LB location and type, the latter will depend on how much load you want it to handle, see https://www.hetzner.com/cloud/load-balancer
  load_balancer_type     = "lb11"
  load_balancer_location = "fsn1"

  ### The following values are entirely optional (and can be removed from this if unused)

  # You can refine a base domain name to be use in this form of nodename.base_domain for setting the reserve dns inside Hetzner
  base_domain = "tambouille.pastis-hosting.net"

  # Cluster Autoscaler
  # Providing at least one map for the array enables the cluster autoscaler feature, default is disabled
  # By default we set a compatible version with the default initial_k3s_channel, to set another one,
  # have a look at the tag value in https://github.com/kubernetes/autoscaler/blob/master/charts/cluster-autoscaler/values.yaml
  # ⚠️ Based on how the autoscaler works with this project, you can only choose either x86 instances or ARM server types for ALL autoscaler nodepools.
  # If you are curious, it's ok to have a multi-architecture cluster, as most underlying container images are multi-architecture too.
  #
  # ⚠️ Setting labels and taints will only work on cluster-autoscaler images versions released after > 20 October 2023. Or images built from master after that date.
  #
  # * Example below:
  # autoscaler_nodepools = [
  #   { 
  #     name        = "autoscaled-small"
  #     server_type = "cpx21"
  #     location    = "fsn1"
  #     min_nodes   = 0
  #     max_nodes   = 3
  #     labels      = {
  #       "node.kubernetes.io/role": "peak-workloads"
  #     }
  #     taints = [{
  #        key: "node.kubernetes.io/role"
  #        value: "peak-workloads"
  #        effect: "NoExecute"
  #     }]
  #   }
  # ]

  # Configuration of the Cluster Autoscaler binary
  #
  # These arguments and variables are not used if autoscaler_nodepools is not set, because the Cluster Autoscaler is installed only if autoscaler_nodepools is set.
  #
  # Image and version of Kubernetes Cluster Autoscaler for Hetzner Cloud:
  #   - cluster_autoscaler_image: Image of Kubernetes Cluster Autoscaler for Hetzner Cloud to be used.
  #   - cluster_autoscaler_version: Version of Kubernetes Cluster Autoscaler for Hetzner Cloud. Should be aligned with Kubernetes version.
  #
  # Logging related arguments are managed using separate variables:
  #   - cluster_autoscaler_log_level: Controls the verbosity of logs (--v), the value is from 0 to 5, default is 4, for max debug info set it to 5.
  #   - cluster_autoscaler_log_to_stderr: Determines whether to log to stderr (--logtostderr).
  #   - cluster_autoscaler_stderr_threshold: Sets the threshold for logs that go to stderr (--stderrthreshold).
  #
  # Example (using the default values):
  #
  # cluster_autoscaler_image = "registry.k8s.io/autoscaling/cluster-autoscaler"
  # cluster_autoscaler_version = "v1.27.3"
  # cluster_autoscaler_log_level = 4
  # cluster_autoscaler_log_to_stderr = true
  # cluster_autoscaler_stderr_threshold = "INFO"

  # Additional Cluster Autoscaler binary configuration
  #
  # cluster_autoscaler_extra_args can be used for additional arguments. The default is an empty array.
  #
  # Please note that following arguments are managed by terraform-hcloud-kube-hetzner or the variables above and should not be set manually:
  #   - --v=${var.cluster_autoscaler_log_level}
  #   - --logtostderr=${var.cluster_autoscaler_log_to_stderr}
  #   - --stderrthreshold=${var.cluster_autoscaler_stderr_threshold}
  #   - --cloud-provider=hetzner
  #   - --nodes ...
  #
  # See the Cluster Autoscaler FAQ for the full list of arguments: https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-are-the-parameters-to-ca
  #
  # Example:
  #
  # cluster_autoscaler_extra_args = [
  #   "--ignore-daemonsets-utilization=true",
  #   "--enforce-node-group-min-size=true",
  # ]

  # Enable etcd snapshot backups to S3 storage.
  # Just provide a map with the needed settings (according to your S3 storage provider) and backups to S3 will
  # be enabled (with the default settings for etcd snapshots).
  # Cloudflare's R2 offers 10GB, 10 million reads and 1 million writes per month for free.
  # For proper context, have a look at https://docs.k3s.io/datastore/backup-restore.
  # etcd_s3_backup = {
  #   etcd-s3-endpoint        = "bb7602930482a97a4a403a52a17cb524.r2.cloudflarestorage.com"
  #   etcd-s3-access-key      = "9bdee5bb414eac87d8f116a5a20f0bfd"
  #   etcd-s3-secret-key      = "56801673c7f700f0ff7e44e59d61eca728a7440eb423c087241a090f2f6072f4"
  #   etcd-s3-bucket          = cloudflare_r2_bucket.tambouille.name
  # }

  # To enable Hetzner Storage Box support, you can enable csi-driver-smb, default is "false".
  enable_csi_driver_smb = false

  # IP Addresses to use for the DNS Servers, the defaults are the ones provided by Hetzner https://docs.hetzner.com/dns-console/dns/general/recursive-name-servers/.
  # The number of different DNS servers is limited to 3 by Kubernetes itself.
  # It's always a good idea to have at least 1 IPv4 and 1 IPv6 DNS server for robustness.
  dns_servers = [
    "1.1.1.1",
    "8.8.8.8",
    "2606:4700:4700::1111",
  ]

  # lb_hostname Configuration:
  #
  # Purpose:
  # The lb_hostname setting optimizes communication between services within the Kubernetes cluster
  # when they use domain names instead of direct service names. By associating a domain name directly
  # with the Hetzner Load Balancer, this setting can help reduce potential communication delays.
  #
  # Scenario:
  # If Service B communicates with Service A using a domain (e.g., `a.mycluster.domain.com`) that points
  # to an external Load Balancer, there can be a slowdown in communication.
  #
  # Guidance:
  # - If your internal services use domain names pointing to an external LB, set lb_hostname to a domain
  #   like `mycluster.domain.com`.
  # - Create an A record pointing `mycluster.domain.com` to your LB's IP.
  # - Create a CNAME record for `a.mycluster.domain.com` (or xyz.com) pointing to `mycluster.domain.com`.
  #
  # Technical Note:
  # This setting sets the `load-balancer.hetzner.cloud/hostname` in the Hetzner LB definition, suitable for
  # both Nginx and Traefik ingress controllers.
  #
  # Recommendation:
  # This setting is optional. If services communicate using direct service names, you can leave this unset.
  # For inter-namespace communication, use `.service_name` as per Kubernetes norms.
  #
  # Example:
  # lb_hostname = "mycluster.domain.com"

  # Extra commands to be executed after the `kubectl apply -k` (useful for post-install actions, e.g. wait for CRD, apply additional manifests, etc.).
  # extra_kustomize_deployment_commands=""

  # Extra values that will be passed to the `extra-manifests/kustomization.yaml.tpl` if its present.
  # extra_kustomize_parameters={}

  # See an working example for just a manifest.yaml, a HelmChart and a HelmChartConfig examples/kustomization_user_deploy/README.md

  # It is best practice to turn this off, but for backwards compatibility it is set to "true" by default.
  # See https://github.com/kube-hetzner/terraform-hcloud-kube-hetzner/issues/349
  # When "false". The kubeconfig file can instead be created by executing: "terraform output --raw kubeconfig > cluster_kubeconfig.yaml"
  # Always be careful to not commit this file!
  create_kubeconfig = false

  # Don't create the kustomize backup. This can be helpful for automation.
  create_kustomization = false

  ### ADVANCED - Custom helm values for packages above (search _values if you want to located where those are mentioned upper in this file)
  # ⚠️ Inside the _values variable below are examples, up to you to find out the best helm values possible, we do not provide support for customized helm values.
  # Please understand that the indentation is very important, inside the EOTs, as those are proper yaml helm values.
  # We advise you to use the default values, and only change them if you know what you are doing!

  # csi-driver-smb, all csi-driver-smb helm values can be found at https://github.com/kubernetes-csi/csi-driver-smb/blob/master/charts/latest/csi-driver-smb/values.yaml
  # The following is an example, please note that the current indentation inside the EOT is important.
  /*   csi_driver_smb_values = <<EOT
controller:
  name: csi-smb-controller
  replicas: 1
  runOnMaster: false
  runOnControlPlane: false
  resources:
    csiProvisioner:
      limits:
        memory: 300Mi
      requests:
        cpu: 10m
        memory: 20Mi
    livenessProbe:
      limits:
        memory: 100Mi
      requests:
        cpu: 10m
        memory: 20Mi
    smb:
      limits:
        memory: 200Mi
      requests:
        cpu: 10m
        memory: 20Mi
  EOT */
}
