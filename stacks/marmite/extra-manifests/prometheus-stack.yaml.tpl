---
apiVersion: v1
kind: Namespace
metadata:
  name: prometheus
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: prometheus
  namespace: kube-system
spec:
  chart: kube-prometheus-stack
  targetNamespace: prometheus
  repo: https://prometheus-community.github.io/helm-charts
  version: 55.8.1
