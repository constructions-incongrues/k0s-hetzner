# Homer
module "homer" {
  source = "../../modules/homer"

  namespace = "tambouille-system"
  config = file("files/homer.yaml")
  host = "www.constructions-incongrues.net"
}