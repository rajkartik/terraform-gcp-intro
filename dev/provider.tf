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
    kubernetes={
      source="hashicorp/kubernetes"
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
# data "google_client_config" "default" {}

# provider "kubernetes" {
#   host                   = "https://${module.cluster_1.endpoint}"
#   token                  = data.google_client_config.default.access_token
#   cluster_ca_certificate = base64decode(module.cluster_1.ca_certificate)
# }
