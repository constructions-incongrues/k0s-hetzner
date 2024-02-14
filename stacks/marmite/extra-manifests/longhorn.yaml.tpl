---
apiVersion: v1
kind: Namespace
metadata:
  name: longhorn-system
---
apiVersion: v1
kind: Secret
metadata:
   name: longhorn-backup-target
   namespace: longhorn-system
type: Opaque
stringData:
  AWS_ACCESS_KEY_ID: ${objectstorage_access_key_id}
  AWS_SECRET_ACCESS_KEY: ${objectstorage_access_key_secret}
  AWS_ENDPOINTS: ${objectstorage_endpoint}
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: longhorn
  namespace: kube-system
spec:
  chart: longhorn
  targetNamespace: longhorn-system
  repo: https://charts.longhorn.io
  version: 1.6.0
  valuesContent: |- 
    persistence:
      # -- Setting that allows you to specify the default Longhorn StorageClass
      defaultClass: longhorn
      # -- Replica count of the default Longhorn StorageClass.
      defaultClassReplicaCount: 1
    defaultSettings:
      # -- Endpoint used to access the backupstore. (Options: "NFS", "CIFS", "AWS", "GCP", "AZURE")
      backupTarget: s3://${objectstorage_bucket}@auto/longhorn
      # -- Name of the Kubernetes secret associated with the backup target.
      backupTargetCredentialSecret: longhorn-backup-target
      # -- Setting that automatically rebalances replicas when an available node is discovered.
      replicaAutoBalance: true
      # -- Default number of replicas for volumes created using the Longhorn UI. For Kubernetes configuration, modify the `numberOfReplicas` field in the StorageClass. The default value is "3".
    longhornUI:
      # -- Replica count for Longhorn UI.
      replicas: 1
---
kind: VolumeSnapshotClass
apiVersion: snapshot.storage.k8s.io/v1
metadata:
  name: longhorn-backup
  labels:
    velero.io/csi-volumesnapshot-class: "true"
driver: driver.longhorn.io
deletionPolicy: Delete
parameters:
  type: bak
---
kind: VolumeSnapshotClass
apiVersion: snapshot.storage.k8s.io/v1
metadata:
  name: longhorn-snapshot
driver: driver.longhorn.io
deletionPolicy: Delete
parameters:
  type: snap
