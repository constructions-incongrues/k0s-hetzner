---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: snapshot-controller
  namespace: kube-system
spec:
  chart: snapshot-controller
  targetNamespace: kube-system
  repo: https://piraeus.io/helm-charts/
  version: 2.1.0
