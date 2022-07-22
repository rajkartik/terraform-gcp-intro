module "vpc" {
  source     = "../modules/net-vpc"
  project_id = "automategcp"
  name       = "my-network-cicd"
  psa_config = {
    ranges = { vpc-private-connect = "/20"
     }
    routes = null
  }
  

#   subnets = [
#     {
#       ip_cidr_range = "10.0.0.0/24"
#       name          = "subnet-1"
#       private_ip_google_access=true
#       region        = "europe-west1"
#       secondary_ip_range = {
#         pods     = "192.16.0.0/20"
#         services = "192.168.0.0/24"
#       }
#     }
#   ]
 
}
# resource "google_cloudbuild_worker_pool" "cicd_private_pool" {
#   name = "cicd-private-pool"
#   project = "automategcp"
#   location = "europe-west1"
#   worker_config {
#     disk_size_gb = 100
#     machine_type = "e2-standard-2"
#     no_external_ip = false
#   }
#   network_config {
#     peered_network = module.vpc.network.id
#   }
#   depends_on = [module.vpc]
# }
# resource "google_project_service" "servicenetworking" {
#     project =  "automategcp"
#   service = "servicenetworking.googleapis.com"
#   disable_on_destroy = false
# }

# resource "google_compute_network" "network" {
#   name                    = "my-cicd-2"
#   project =  "automategcp"
#   auto_create_subnetworks = false
#   depends_on = [google_project_service.servicenetworking]
# }

# resource "google_compute_global_address" "worker_range" {
#   name          = "worker-pool-range"
#   project =  "automategcp"
#   purpose       = "VPC_PEERING"
#   address_type  = "INTERNAL"
#   prefix_length = 20
#   network       = google_compute_network.network.id
# }

# resource "google_service_networking_connection" "worker_pool_conn" {
#   network                 = google_compute_network.network.id
#   service                 = "servicenetworking.googleapis.com"
#   reserved_peering_ranges = [google_compute_global_address.worker_range.name]
#   depends_on              = [google_project_service.servicenetworking]
# }

# resource "google_cloudbuild_worker_pool" "pool" {
#   name = "my-pool"
#   project =  "automategcp"
#   location = "europe-west1"
#   worker_config {
#     disk_size_gb = 100
#     machine_type = "e2-standard-2"
#     no_external_ip = false
#   }
#   network_config {
#     peered_network = google_compute_network.network.id
#   }
#   depends_on = [google_service_networking_connection.worker_pool_conn]
# }
module "peering-a-b" {
  source        = "../modules/net-vpc-peering"
  prefix        = "name-prefix"
  local_network = "projects/automategcp/global/networks/my-network-cicd"
  peer_network  = "projects/automategcp/global/networks/my-network-module"
}
