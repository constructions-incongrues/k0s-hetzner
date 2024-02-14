resource "tfe_variable_set" "main" {
  name = "main"
  
  workspace_ids = [
    tfe_workspace.marmite.id,
  ]
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
  value = var.cloudflare_email
}

resource "tfe_variable" "hcloud_api_token" {
  category = "terraform"
  key = "hcloud_api_token"
  sensitive = true
  variable_set_id = tfe_variable_set.main.id
  value = var.hcloud_api_token
}

resource "tfe_variable" "cloudflare_r2_account_id" {
  category = "terraform"
  key = "cloudflare_r2_account_id"
  sensitive = true
  variable_set_id = tfe_variable_set.main.id
  value = var.cloudflare_r2_account_id
}

resource "tfe_variable" "objectstorage_access_key_id" {
  category = "terraform"
  key = "objectstorage_access_key_id"
  sensitive = true
  variable_set_id = tfe_variable_set.main.id
  value = var.objectstorage_access_key_id
}

resource "tfe_variable" "objectstorage_access_key_secret" {
  category = "terraform"
  key = "objectstorage_access_key_secret"
  sensitive = true
  variable_set_id = tfe_variable_set.main.id
  value = var.objectstorage_access_key_secret
}

resource "tfe_variable" "objectstorage_endpoint" {
  category = "terraform"
  key = "objectstorage_endpoint"
  sensitive = true
  variable_set_id = tfe_variable_set.main.id
  value = var.objectstorage_endpoint
}

resource "tfe_variable" "objectstorage_bucket" {
  category = "terraform"
  key = "objectstorage_bucket"
  sensitive = true
  variable_set_id = tfe_variable_set.main.id
  value = var.objectstorage_bucket
}

resource "tfe_project" "tambouille" {
  name = "tambouille"
}

resource "tfe_workspace" "marmite" {
  name = "marmite"
  project_id = tfe_project.tambouille.id

  vcs_repo {
    branch             = "main"
    identifier         = "constructions-incongrues/tambouille"
    github_app_installation_id = data.tfe_github_app_installation.constructions-incongrues.id
  }

  working_directory = "stacks/marmite"
}

data "tfe_github_app_installation" "constructions-incongrues" {
  name = "constructions-incongrues"
}