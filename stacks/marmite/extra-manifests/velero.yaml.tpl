---
apiVersion: v1
kind: Namespace
metadata:
  name: velero
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: velero
  namespace: kube-system
spec:
  chart: velero
  targetNamespace: velero
  repo: https://vmware-tanzu.github.io/helm-charts
  version: 5.3.0
  valuesContent: |-
    initContainers:
      - name: velero-plugin-for-aws
        image: velero/velero-plugin-for-aws:v1.9.0
        imagePullPolicy: IfNotPresent
        volumeMounts:
          - mountPath: /target
            name: plugins
      - name: velero-plugin-for-csi
        image: velero/velero-plugin-for-csi:v0.7.0
        imagePullPolicy: IfNotPresent
        volumeMounts:
          - mountPath: /target
            name: plugins
    configuration:
      # Parameters for the BackupStorageLocation(s). Configure multiple by adding other element(s) to the backupStorageLocation slice.
      # See https://velero.io/docs/v1.6/api-types/backupstoragelocation/
      backupStorageLocation:
      - name: default
        provider: velero.io/aws
        bucket: tambouille
        default: true
        prefix: velero
        credential:
          name: velero-credentials
          key: cloud
        config: 
          region: auto
          s3Url: https://${objectstorage_endpoint}
      volumeSnapshotLocation:
      - name: default
        provider: velero.io/aws
        prefix: velero
        credential:
          name: velero-credentials
          key: cloud
        config: 
          region: auto

      defaultVolumesToFsBackup: false
      defaultRepoMaintainFrequency: 5m

      features: EnableCSI

    credentials:
      useSecret: true
      name: velero-credentials
      existingSecret:
      secretContents: 
       cloud: |
         [default]
         aws_access_key_id=${objectstorage_access_key_id}
         aws_secret_access_key=${objectstorage_access_key_secret}

    backupsEnabled: true
    snapshotsEnabled: true
    deployNodeAgent: false

    # Backup schedules to create.
    # Eg:
    # schedules:
    #   mybackup:
    #     disabled: false
    #     labels:
    #       myenv: foo
    #     annotations:
    #       myenv: foo
    #     schedule: "0 0 * * *"
    #     useOwnerReferencesInBackup: false
    #     template:
    #       ttl: "240h"
    #       storageLocation: default
    #       includedNamespaces:
    #       - foo
    schedules: {}
    