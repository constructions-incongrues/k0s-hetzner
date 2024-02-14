terraform {
  cloud {
    organization = "constructions-incongrues"

    workspaces {
      name = "tambouille"
    }
  }
}