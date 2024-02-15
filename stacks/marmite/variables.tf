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

variable "nodepool_servers" {
  type = object({
    count = number
    location = string
    type = string
  })

  default = {
    count = 3
    location = "fsn1"
    type = "cx11"
  }
}

variable "nodepool_agents_workers" {
  type = object({
    count = number
    location = string
    type = string
  })

  default = {
    count = 3
    location = "fsn1"
    type = "cx11"
  }
}

variable "nodepool_agents_storage" {
  type = object({
    count = number
    location = string
    type = string
    longhorn_volume_size = number
  })

  default = {
    count = 3
    location = "fsn1"
    type = "cx11"
    longhorn_volume_size = 50
  }
}

variable "juicefs_kdrive_bucket" {
  sensitive = true
  nullable = false
}
variable "juicefs_kdrive_accesskey" {
  sensitive = true
  nullable = false
}
variable "juicefs_kdrive_secretkey" {
  sensitive = true
  nullable = false
}

variable "disable_selinux" {
  type = bool
  default = false
}