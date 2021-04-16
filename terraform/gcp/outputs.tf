output "public_ip" {
  value = google_compute_instance.rails_demo.network_interface.0.access_config.0.nat_ip
}

output "public_url" {
  value = "http://${google_dns_record_set.resource-recordset.name}/"
}