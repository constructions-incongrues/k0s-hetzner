```hcl

# Epinio
resource "kubernetes_secret" "dex-config" {
  metadata {
    name = "dex-config"
    namespace = "epinio"
    labels = {
      "app.kubernetes.io/managed-by" = "Helm"
    }
    annotations = {
      "meta.helm.sh/release-name" = "epinio"
      "meta.helm.sh/release-namespace" = "epinio"
    }
  }

  data = {
    "config.yaml" = <<-EOT
issuer: "https://auth.tambouille.pastis-hosting.net"
storage:
  type: kubernetes
  config:
    inCluster: true
oauth2:
  skipApprovalScreen: true
enablePasswordDB: false

connectors:
  - type: github
    id: github
    name: GitHub
    config:
      clientID: f84166223164a9d0a9ff
      clientSecret: 64fba3c165dd52d7d9e7685c18292774c74a46b7
      redirectURI: "https://auth.tambouille.pastis-hosting.net/callback"
      orgs:
      - name: constructions-incongrues
        teams:
          - tambouille
      teamNameField: slug

staticClients:
- id: epinio-api
  name: 'Epinio API'
  public: true
  # The 'Epinio API' lets the 'Epinio cli' issue ID tokens on its behalf.
  # https://dexidp.io/docs/custom-scopes-claims-clients/#cross-client-trust-and-authorized-party
  trustedPeers:
  - epinio-cli
  - epinio-ui

- id: epinio-cli
  name: 'Epinio cli'
  public: true

- id: epinio-ui
  name: 'Epinio UI'
  secret: "TD2LZQLX9FiTRvszMoRauHJ6OU5Ni7yn"
  # Shouldn't be public, https://dexidp.io/docs/custom-scopes-claims-clients/#public-clients
  redirectURIs:
  - "https://epinio.tambouille.pastis-hosting.net/auth/verify/"
    EOT
    endpoint = "http://dex.epinio.svc.cluster.local:5556"
    issuer = "https://auth.tambouille.pastis-hosting.net"
    uiClientSecret = "TD2LZQLX9FiTRvszMoRauHJ6OU5Ni7yn"
  }

  type = "Opaque"
}

resource "helm_release" "epinio" {
  chart = "epinio"
  repository = "https://epinio.github.io/helm-charts/"
  version = "1.11.0"
  name = "epinio"

  depends_on = [ helm_release.hcloud-ccm, helm_release.hcloud-csi, kubernetes_secret.dex-config ]
  namespace = "epinio"
  create_namespace = true

  values = [file("./epinio-values.yaml")]

  set {
     name = "certManagerNamespace"
     value = module.cert-manager.namespace
  }

  set {
     name = "global.customTlsIssuer"
     value = module.cert-manager.cluster_issuer_name
  }
}

resource "helm_release" "portainer" {
  chart = "portainer"
  repository = "https://portainer.github.io/k8s/"
  version = "1.0.49"
  name = "portainer"

  depends_on = [ helm_release.hcloud-ccm, helm_release.hcloud-csi ]
  namespace = "portainer"
  create_namespace = true

  values = [file("./portainer-values.yaml")]
}
```

```hcl
# Homer
resource "helm_release" "homer" {
  chart = "homer"
  repository = "https://charts.gabe565.com"
  version = "0.9.0"
  name = "homer"

  depends_on = [ helm_release.hcloud-ccm, helm_release.hcloud-csi ]
  namespace = "homer"
  create_namespace = true

  values = [file("./homer-values.yaml")]
}
``````