terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "constructions-incongrues"

    workspaces {
      name = "marmite"
    }
  }
}