variable "hcloud_api_token" {
  description = "Hetzner API token"
  type        = string
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

variable "controllers_server_type" {
  type = string
  default = "cpx11"
}

variable "controllers_count" {
  type = number
  default = 1
}

variable "workers_server_type" {
  type = string
  default = "cpx11"
}

variable "workers_count" {
  type = number
  default = 1
}