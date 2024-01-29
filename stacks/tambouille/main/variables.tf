variable "hcloud_api_token" {
  description = "Hetzner API token"
  type        = string
  default     = ""
}

variable "cloudflare_email" {
  type = string
}

variable "cloudflare_api_key" {
  type = string
}

variable "github_token" {
  type = string
}

variable "certmanager_email" {
  type = string
}