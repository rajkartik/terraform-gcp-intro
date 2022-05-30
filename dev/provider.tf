terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.0"
    }
  }
}

provider "google-beta" {
  project = var.project_id
  region = var.region
 
  
}

provider "google" {
    project = var.project_id
    region = var.region
    
    
}