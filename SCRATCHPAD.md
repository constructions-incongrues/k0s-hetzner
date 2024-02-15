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
```
```yalm
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: juicefs-kdrive-pvc
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
  storageClassName: juicefs-kdrive
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-run
  labels:
    app: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: linuxserver/nginx
          ports:
            - containerPort: 80
          volumeMounts:
            - mountPath: /config
              name: web-data
      volumes:
        - name: web-data
          persistentVolumeClaim:
            claimName: juicefs-kdrive-pvc-1


    spec:
      volumes:
        - name: kubelet-dir
          hostPath:
            path: /var/lib/kubelet
            type: Directory
        - name: plugin-dir
          hostPath:
            path: /var/lib/kubelet/plugins/csi.juicefs.com/
            type: DirectoryOrCreate
        - name: registration-dir
          hostPath:
            path: /var/lib/kubelet/plugins_registry/
            type: Directory
        - name: device-dir
          hostPath:
            path: /dev
            type: Directory
        - name: jfs-dir
          hostPath:
            path: /var/lib/juicefs/volume
            type: DirectoryOrCreate
        - name: jfs-root-dir
          hostPath:
            path: /var/lib/juicefs/config
            type: DirectoryOrCreate
      containers:
        - name: juicefs-plugin
          image: juicedata/juicefs-csi-driver:v0.23.3
          args:
            - '--endpoint=$(CSI_ENDPOINT)'
            - '--logtostderr'
            - '--nodeid=$(NODE_NAME)'
            - '--v=5'
            - '--enable-manager=true'
          ports:
            - name: healthz
              containerPort: 9909
              protocol: TCP
          env:
            - name: CSI_ENDPOINT
              value: unix:/csi/socket
            - name: NODE_NAME
              valueFrom:
                fieldRef:
                  apiVersion: v1
                  fieldPath: spec.nodeName
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  apiVersion: v1
                  fieldPath: metadata.name
            - name: JUICEFS_MOUNT_NAMESPACE
              valueFrom:
                fieldRef:
                  apiVersion: v1
                  fieldPath: metadata.namespace
            - name: HOST_IP
              valueFrom:
                fieldRef:
                  apiVersion: v1
                  fieldPath: status.hostIP
            - name: KUBELET_PORT
              value: '10250'
            - name: JUICEFS_MOUNT_PATH
              value: /var/lib/juicefs/volume
            - name: JUICEFS_CONFIG_PATH
              value: /var/lib/juicefs/config
          resources:
            limits:
              cpu: '1'
              memory: 1Gi
            requests:
              cpu: 100m
              memory: 512Mi
          volumeMounts:
            - name: kubelet-dir
              mountPath: /var/lib/kubelet
              mountPropagation: Bidirectional
            - name: plugin-dir
              mountPath: /csi
            - name: device-dir
              mountPath: /dev
            - name: jfs-dir
              mountPath: /jfs
              mountPropagation: Bidirectional
            - name: jfs-root-dir
              mountPath: /root/.juicefs
              mountPropagation: Bidirectional
          livenessProbe:
            httpGet:
              path: /healthz
              port: healthz
              scheme: HTTP
            initialDelaySeconds: 10
            timeoutSeconds: 3
            periodSeconds: 10
            successThreshold: 1
            failureThreshold: 5
          lifecycle:
            preStop:
              exec:
                command:
                  - /bin/sh
                  - '-c'
                  - rm /csi/socket
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
          imagePullPolicy: IfNotPresent
          securityContext:
            privileged: true
        - name: node-driver-registrar
          image: quay.io/k8scsi/csi-node-driver-registrar:v2.1.0
          args:
            - '--csi-address=$(ADDRESS)'
            - '--kubelet-registration-path=$(DRIVER_REG_SOCK_PATH)'
            - '--v=5'
          env:
            - name: ADDRESS
              value: /csi/socket
            - name: DRIVER_REG_SOCK_PATH
              value: /var/lib/kubelet/plugins/csi.juicefs.com/socket
          resources: {}
          volumeMounts:
            - name: plugin-dir
              mountPath: /csi
            - name: registration-dir
              mountPath: /registration
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
          imagePullPolicy: IfNotPresent
        - name: liveness-probe
          image: quay.io/k8scsi/livenessprobe:v1.1.0
          args:
            - '--csi-address=$(ADDRESS)'
            - '--health-port=$(HEALTH_PORT)'
          env:
            - name: ADDRESS
              value: /csi/socket
            - name: HEALTH_PORT
              value: '9909'
          resources: {}
          volumeMounts:
            - name: plugin-dir
              mountPath: /csi
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
          imagePullPolicy: IfNotPresent
      restartPolicy: Always
      terminationGracePeriodSeconds: 30
      dnsPolicy: ClusterFirstWithHostNet
      serviceAccountName: juicefs-csi-node-sa
      serviceAccount: juicefs-csi-node-sa
      securityContext: {}
      schedulerName: default-scheduler
      tolerations:
        - key: CriticalAddonsOnly
          operator: Exists
      priorityClassName: system-node-critical
