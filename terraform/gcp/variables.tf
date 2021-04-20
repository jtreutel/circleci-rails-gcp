#Mandatory variables

variable "gcp_region" {
  type        = string
  description = "GCP region in which resources will be created."
}

variable "gcp_project_name" {
  type        = string
  description = "GCP project in which resources will be created."
}

variable "google_dns_zone_name" {
  type        = string
  description = "Name of an existing Google DNS Managed Zone that will host a DNS record for this demo."
}

#Optional variables

variable "commit_hash" {
  type        = string
  default     = ""
  description = "Optionally use a commit hash instead of a randomly generated ID."
}

variable "machine_type" {
  type        = string
  default     = "e2-medium"
  description = "Google Compute Instance type used for hosting demo Rails app."
}

variable "image_name" {
  type        = string
  default     = "ubuntu-2004-focal-v20210413"
  description = "Google Compute Instance boot disk image name."
}

variable "allowed_source_ip_ranges" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "IP ranges allowed to send traffic to Rails web server."
}