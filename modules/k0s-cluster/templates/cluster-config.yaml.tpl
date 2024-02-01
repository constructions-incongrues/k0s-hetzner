apiVersion: k0s.k0sproject.io/v1beta1
kind: ClusterConfig
metadata:
  name: k0s
spec:
  api:
    address: ${controller_nodes[0].ipv4_address}
    port: 443
    k0sApiPort: 9443
    externalAddress: ${controller_nodes[0].ipv4_address}
    sans:
      - ${controller_nodes[0].ipv4_address}
  storage:
    type: etcd
    etcd:
      peerAddress: ${controller_nodes[0].ipv4_address}
  network:
    provider: kuberouter
    calico: null
    kuberouter:
      mtu: 0
      peerRouterIPs: ""
      peerRouterASNs: ""
      autoMTU: true
  podSecurityPolicy:
    defaultPolicy: 00-k0s-privileged
  telemetry:
    enabled: false
  installConfig:
    users:
      etcdUser: etcd
      kineUser: kube-apiserver
      konnectivityUser: konnectivity-server
      kubeAPIserverUser: kube-apiserver
      kubeSchedulerUser: kube-scheduler
  konnectivity:
    agentPort: 8132
    adminPort: 8133
