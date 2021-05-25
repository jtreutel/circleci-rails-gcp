## Create Google Compute Instance and run bash script to install application
resource "google_compute_instance" "rails_demo" {
  name         = "circleci-rails-demo-${var.commit_hash != "" ? var.commit_hash : random_id.dns_name.hex}"
  machine_type = var.machine_type
  zone         = "${var.gcp_region}-a"

  boot_disk {
    initialize_params {
      image = var.image_name
    }
  }

  network_interface {
    network = "default"
    access_config {} #Attached ephemeral public IP
  }

  metadata_startup_script = file("${path.module}/../userdata/install.sh") #Installs Rails demo app
  tags                    = ["http-server"]
}




## Create firewall rules to allow traffic to web server
resource "google_compute_firewall" "http-server" {
  name    = "default-allow-http-terraform"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = var.allowed_source_ip_ranges
  target_tags   = ["http-server"]
}




## Create record set in Google DNS Managed Zone
resource "google_dns_record_set" "resource-recordset" {
  managed_zone = data.google_dns_managed_zone.production.name
  name         = "railsdemo-${var.commit_hash != "" ? var.commit_hash : random_id.dns_name.hex}.ccigcp.jtreutel.io."
  type         = "A"
  rrdatas      = [google_compute_instance.rails_demo.network_interface.0.access_config.0.nat_ip]
  ttl          = 120
}