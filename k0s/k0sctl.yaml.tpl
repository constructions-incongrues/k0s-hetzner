apiVersion: k0sctl.k0sproject.io/v1beta1
kind: Cluster
metadata:
  name: k0s-cluster
spec:
  hosts:
  - ssh:
      address: 10.250.0.100
      user: root
      port: 22
      keyPath: ~/.ssh/id_rsa
      bastion:
        address: ${public-bastionhost-address}
        user: root
        keyPath: ~/.ssh/id_rsa
    role: controller+worker
    privateAddress: 10.250.0.100
    installFlags:
    - --kubelet-extra-args=--cloud-provider=external
  - ssh:
      address: 10.250.0.101
      user: root
      port: 22
      keyPath: ~/.ssh/id_rsa
      bastion:
        address: ${public-bastionhost-address}
        user: root
        keyPath: ~/.ssh/id_rsa
    role: controller+worker
    privateAddress: 10.250.0.101
    installFlags:
    - --kubelet-extra-args=--cloud-provider=external
  - ssh:
      address: 10.250.0.102
      user: root
      port: 22
      keyPath: ~/.ssh/id_rsa
      bastion:
        address: ${public-bastionhost-address}
        user: root
        keyPath: ~/.ssh/id_rsa
    role: controller+worker
    privateAddress: 10.250.0.102
    installFlags:
    - --kubelet-extra-args=--cloud-provider=external
  - ssh:
      address: 10.250.0.200
      user: root
      port: 22
      keyPath: ~/.ssh/id_rsa
      bastion:
        address: ${public-bastionhost-address}
        user: root
        keyPath: ~/.ssh/id_rsa
    role: worker
    privateAddress: 10.250.0.200
    installFlags:
    - --kubelet-extra-args=--cloud-provider=external
  - ssh:
      address: 10.250.0.201
      user: root
      port: 22
      keyPath: ~/.ssh/id_rsa
      bastion:
        address: ${public-bastionhost-address}
        user: root
        keyPath: ~/.ssh/id_rsa
    role: worker
    privateAddress: 10.250.0.201
    installFlags:
    - --kubelet-extra-args=--cloud-provider=external
  - ssh:
      address: 10.250.0.202
      user: root
      port: 22
      keyPath: ~/.ssh/id_rsa
      bastion:
        address: ${public-bastionhost-address}
        user: root
        keyPath: ~/.ssh/id_rsa
    role: worker
    privateAddress: 10.250.0.202
    installFlags:
    - --kubelet-extra-args=--cloud-provider=external
  k0s:
    version: 1.24.4+k0s.0
    config:
      apiVersion: k0s.k0sproject.io/v1beta1
      kind: Cluster
      metadata:
        name: hetzner-k0s
      spec:
        api:
          externalAddress: ${loadbalancer-address}
          sans:
          - ${loadbalancer-address}
          - 10.250.0.100
          - 10.250.0.101
          - 10.250.0.102
          k0sApiPort: 9443
          port: 6443
        installConfig:
          users:
            etcdUser: etcd
            kineUser: kube-apiserver
            konnectivityUser: konnectivity-server
            kubeAPIserverUser: kube-apiserver
            kubeSchedulerUser: kube-scheduler
        konnectivity:
          adminPort: 8133
          agentPort: 8132
        network:
          kubeProxy:
            disabled: false
            mode: iptables
          kuberouter:
            autoMTU: true
            mtu: 0
            peerRouterASNs: ""
            peerRouterIPs: ""
          podCIDR: 10.244.0.0/16
          provider: kuberouter
          serviceCIDR: 10.96.0.0/12
        storage:
          type: etcd
        telemetry:
          enabled: true