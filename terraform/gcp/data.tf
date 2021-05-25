# Get data of an existing Google DNS Managed Zone
data "google_dns_managed_zone" "production" {
  name = var.google_dns_zone_name
}

# Random string to prevent name collisions
resource "random_id" "dns_name" {
  byte_length = 4
}