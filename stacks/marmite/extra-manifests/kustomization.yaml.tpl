apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - cert-manager-issuer.yaml
  - external-dns.yaml
  - prometheus-stack.yaml
  - snapshot-controller.yaml
  - longhorn.yaml
  - velero.yaml
  - juicefs.yaml

