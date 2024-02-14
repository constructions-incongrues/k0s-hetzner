---
apiVersion: v1
kind: Secret
metadata:
  name: cloudflare-api-key-secret
  namespace: cert-manager
type: Opaque
stringData:
  api-key: ${cloudflare_api_key}
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: ${cloudflare_email}
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
      - selector: {}
        http01:
          ingress:
            class: traefik
      - selector:
          matchLabels:
            use-cloudflare-solver: "true"
        dns01:
          # Adjust the configuration below according to your environment.
          # You can view more example configurations for different DNS01
          # providers in the documentation: https://docs.cert-manager.io/en/latest/tasks/issuers/setup-acme/dns01/index.html
          cloudflare:
            email:  ${cloudflare_email}
            apiKeySecretRef:
              name: cloudflare-api-key-secret
              key: api-key
