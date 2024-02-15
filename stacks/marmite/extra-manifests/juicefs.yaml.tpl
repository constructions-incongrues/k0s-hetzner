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
    defaultMountImage:
      ce: "constructionsincongrues/juicefs-csi-mount:ce-v1.1.2-static"
    sidecars:
      livenessProbeImage:
        repository: registry.k8s.io/sig-storage/livenessprobe
        tag: "v2.11.0"
      nodeDriverRegistrarImage:
        repository: registry.k8s.io/sig-storage/csi-node-driver-registrar
        tag: "v2.9.0"
      csiProvisionerImage:
        repository: registry.k8s.io/sig-storage/csi-provisioner
        tag: "v3.6.0"
      csiResizerImage:
        repository: registry.k8s.io/sig-storage/csi-resizer
        tag: "v1.9.0"
    mountMode: mountpod
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
