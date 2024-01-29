#
# IMPORTANT NOTE
#
# This chart inherits from our common library chart. You can check the default values/options here:
# https://github.com/bjw-s/helm-charts/blob/a081de5/charts/library/common/values.yaml
#

ingress:
  # -- Enable and configure ingress settings for the chart under this key.
  # @default -- See [values.yaml](./values.yaml)
  main:
    enabled: true
    hosts:
      - host: ${host}
        paths:
          - path: /

persistence:
  # -- Configure persistence settings for the chart under this key.
  # @default -- See [values.yaml](./values.yaml)
  config:
    enabled: false
    mountPath: /www/assets
    retain: true

configmap:
  config: 
    enabled: true

configMaps:
  config:
    # -- Store homer configuration as a ConfigMap
    enabled: true
    # -- Homer configuration. [[ref]](https://github.com/bastienwirtz/homer/blob/main/docs/configuration.md)
    # @default -- See [values.yaml](./values.yaml)
    data:
      config.yml: |-
        ${indent(8, homer_config)}