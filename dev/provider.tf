terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
        google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 3.57.0"
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