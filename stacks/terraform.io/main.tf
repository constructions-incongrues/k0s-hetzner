data "tfe_organization" "constructions-incongrues" {
  name = "constructions-incongrues"
}

data "tfe_github_app_installation" "constructions-incongrues" {
  name = "constructions-incongrues"
}

resource "tfe_variable_set" "main" {
  name = "main"
  organization = data.tfe_github_app_installation.constructions-incongrues.name
}

resource "tfe_project_variable_set" "tambouille-main" {
  project_id = tfe_project.tambouille.id
  variable_set_id = tfe_variable_set.main.id
}

resource "tfe_variable" "cloudflare_api_key" {
  category = "terraform"
  key = "cloudflare_api_key"
  sensitive = true
  variable_set_id = tfe_variable_set.main.id
}

resource "tfe_variable" "cloudflare_email" {
  category = "terraform"
  key = "cloudflare_email"
  sensitive = true
  variable_set_id = tfe_variable_set.main.id
}

resource "tfe_variable" "certmanager_email" {
  category = "terraform"
  key = "certmanager_email"
  sensitive = false
  variable_set_id = tfe_variable_set.main.id
  value = "contact@pastis-hosting.net"
}

resource "tfe_variable" "hcloud_api_token" {
  category = "terraform"
  key = "hcloud_api_token"
  sensitive = true
  variable_set_id = tfe_variable_set.main.id
}

resource "tfe_variable" "github_token" {
  category = "terraform"
  key = "github_token"
  sensitive = true
  variable_set_id = tfe_variable_set.main.id
}

resource "tfe_project" "tambouille" {
  name = "tambouille"
  organization = data.tfe_organization.constructions-incongrues.name
}

resource "tfe_workspace" "marmite" {
  name = "marmite"
  project_id = tfe_project.tambouille.id
  organization = data.tfe_organization.constructions-incongrues.name

  # vcs_repo {
  #   branch             = "main"
  #   identifier         = "constructions-incongrues/tambouille"
  #   github_app_installation_id = data.tfe_github_app_installation.constructions-incongrues.id
  # }

  working_directory = "stacks/marmite"
}

resource "tfe_workspace" "papinettes" {
  name = "papinettes"
  project_id = tfe_project.tambouille.id
  organization = data.tfe_organization.constructions-incongrues.name

  # vcs_repo {
  #   branch             = "main"
  #   identifier         = "constructions-incongrues/tambouille"
  #   github_app_installation_id = data.tfe_github_app_installation.constructions-incongrues.id
  # }

  working_directory = "stacks/papinettes"
}