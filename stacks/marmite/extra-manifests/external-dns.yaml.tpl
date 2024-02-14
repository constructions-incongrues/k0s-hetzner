---
apiVersion: v1
kind: Namespace
metadata:
  name: external-dns
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: external-dns
  namespace: kube-system
spec:
  chart: external-dns
  targetNamespace: external-dns
  repo: https://charts.bitnami.com/bitnami
  version: 6.31.6
  valuesContent: |-
    sources:
      - ingress
    provider: cloudflare
    cloudflare:
      apiKey: ${cloudflare_api_key}
      email: ${cloudflare_email}
      proxied: ${cloudflare_proxied}

