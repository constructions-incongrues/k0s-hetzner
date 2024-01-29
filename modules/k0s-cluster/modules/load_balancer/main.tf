resource "hcloud_load_balancer" "load_balancer" {
  name               = var.name
  load_balancer_type = var.load_balancer_type
  location           = var.location
}