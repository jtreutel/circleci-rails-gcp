provider "google" {
  project = var.gcp_project_name
  region  = var.gcp_region
  zone    = "${var.gcp_region}-a"
}

terraform {
  backend "gcs" {
    bucket  = "jtreutel-demo-tfstate"
    prefix  = "circleci-rails-gcp"
  }
}