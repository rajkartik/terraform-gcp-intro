module "vpc" {
  source     = "../modules/net-vpc"
  project_id = var.project_id
  name       = "my-network-module"
  
  subnets_proxy_only = [
    {
      ip_cidr_range = "10.0.1.0/24"
      name          = "regional-proxy"
      region        = "europe-west1"
      active        = true
    }
  ]
  subnets_psc = [
    {
      ip_cidr_range = "10.0.3.0/24"
      name          = "psc"
      region        = "europe-west1"
    }
  ]
  depends_on = [
    google_project_service.service
  ]
}
resource "google_project_service" "service" {
  
  for_each = toset([
    "compute.googleapis.com",
    "appengine.googleapis.com",
    "appengineflex.googleapis.com",
    "cloudbuild.googleapis.com",
    "container.googleapis.com",
    "cloudbilling.googleapis.com"

  ])

  service = each.key

  project            = var.project_id
  disable_on_destroy = true
}