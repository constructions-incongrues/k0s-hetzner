---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: juicefs-etcd
  namespace: kube-system
spec:
  chart: etcd
  targetNamespace: kube-system
  repo: https://charts.bitnami.com/bitnami
  version: 9.11.0
  valuesContent: |-
    auth:
      rbac:
        create: false
        allowNoneAuthentication: true
        rootPassword: "root"
      token:
        enabled: false
    persistence:
      enabled: true
      storageClass: "longhorn"
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: juicefs-csi-driver
  namespace: kube-system
spec:
  chart: juicefs-csi-driver
  targetNamespace: kube-system
  repo: https://juicedata.github.io/charts/
  version: 0.19.6
  valuesContent: |- 
    mountMode: mountPod
    storageClasses:
    - name: "juicefs-kdrive"
      enabled: true
      reclaimPolicy: Delete
      allowVolumeExpansion: true
      backend:
        name: "kdrive"
        metaurl: "etcd://root:root@juicefs-etcd.kube-system.svc.cluster.local/kdrive"
        storage: "webdav"
        bucket: ${juicefs_kdrive_bucket}
        accessKey: ${juicefs_kdrive_accesskey}
        secretKey: ${juicefs_kdrive_secretkey}
        trashDays: "7"
