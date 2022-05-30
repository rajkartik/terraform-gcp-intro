terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>3.0"
    }
  }
}

provider "google-beta" {
  project = var.project_id
  region = var.region
  zone   = var.zone
}

provider "google" {
    project = var.project_id
    region = var.region
    zone   = var.zone
}