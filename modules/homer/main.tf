resource "helm_release" "homer" {
  chart = "homer"
  repository = "https://charts.gabe565.com"
  version = "0.9.0"
  name = var.name
  namespace = var.namespace
  create_namespace = true

  values = [templatefile("${path.module}/templates/values.yaml.tpl", {
    host = var.host
    homer_config = var.config
  })]

}