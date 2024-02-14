variable "cloudflare_r2_account_id" {
  type = string
  sensitive = true
  nullable = false
}

variable "cloudflare_api_key" {
  type = string
  sensitive = true
  nullable = false
}

variable "cloudflare_email" {
  type = string
  sensitive = true
  nullable = false
}

variable "hcloud_api_token" {
  sensitive = true
  nullable = false
}

variable "cloudflare_proxied" {
  type = bool
  default = false
}

variable "objectstorage_access_key_id" {
  nullable = false
  sensitive = true
}

variable "objectstorage_access_key_secret" {
  nullable = false
  sensitive = true
}

variable "objectstorage_endpoint" {
  nullable = false
  sensitive = true
}

variable "objectstorage_bucket" {
  nullable = false
  default = "tambouille"
}