module "vpc" {
  source     = "../modules/net-vpc"
  project_id = var.project_id
  name       = "my-network-module"
  psa_config = {
    ranges = { cloud-sql = "10.60.0.0/20" }
    routes = null
  }
  
  subnets_proxy_only = [
    {
      ip_cidr_range = "10.0.1.0/26"
      name          = "regional-proxy"
      region        = "europe-west1"
      active        = true
    }
  ]
  subnets = [
    {
      ip_cidr_range = "10.0.0.0/24"
      name          = var.subnet_gke
      private_ip_google_access=true
      region        = "europe-west1"
      secondary_ip_range = {
        pods     = "192.16.0.0/20"
        services = "192.168.0.0/24"
      }
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
    "cloudbilling.googleapis.com",
    "servicenetworking.googleapis.com"

  ])

  service = each.key

  project            = var.project_id
  disable_on_destroy = true
}
module "db" {
  source           = "../modules/cloudsql-instance"
  project_id       = var.project_id
  network          = module.vpc.network.self_link
  name             = "samp-priv-db"
  region           = "europe-west1"
  database_version = "POSTGRES_13"
  tier             = "db-g1-small"

#  authorized_networks = {
    
#     name="gke-clusters"
#     value="10.0.0.0/24"
    
    
#     }



  depends_on = [
    module.vpc.psa_config
  ]
}
# resource "google_container_cluster" "primary" {
#   name     = "${var.project_id}-gke"
#   location = var.region
#   project_id                = var.project_id
 
 
#   network                   = "my-network-module"
#   subnetwork                = var.subnet-gke
# # Enabling Autopilot for this cluster
#   enable_autopilot = true
#   enable_dataplane_v2=true
#   # secondary_range_pods      = "pods"
#   # secondary_range_services  = "services"
# }
module "cluster-1" {
  source                    = "../modules/gke-cluster"
  project_id                = var.project_id
  name                      = "my-cluster-1"
  location                  = "europe-west1"
  network                   = "my-network-module"
  subnetwork                = var.subnet_gke
  secondary_range_pods      = "pods"
  secondary_range_services  = "services"
 
  enable_dataplane_v2       = true
  enable_autopilot = true
  
  master_authorized_ranges = {
    internal-vms = "10.0.0.0/8"
  }
  private_cluster_config = {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = "172.16.0.32/28"
    master_global_access    = false
  }
  addons = { cloudrun_config            = false
    dns_cache_config           = false
    horizontal_pod_autoscaling = true
    http_load_balancing        = true
    istio_config = {
      enabled = false
      tls     = false
    }
  
    network_policy_config                 = false
    gce_persistent_disk_csi_driver_config = true
    gcp_filestore_csi_driver_config       = true
    config_connector_config               = false
    kalm_config                           = false
    gke_backup_agent_config               = false}
  labels = {
    environment = "dev"
  }
}




# resource "random_id" "name" {
#   byte_length = 2
# }

# locals {
#   # If name_override is specified, use that - otherwise use the name_prefix with a random string
#   instance_name        = var.name_override == null ? format("%s-%s", var.name_prefix, random_id.name.hex) : var.name_override
#   private_network_name = "private-network-${random_id.name.hex}"
#   private_ip_name      = "private-ip-${random_id.name.hex}"
# }

# # ------------------------------------------------------------------------------
# # CREATE COMPUTE NETWORKS
# # ------------------------------------------------------------------------------

# # Simple network, auto-creates subnetworks
# resource "google_compute_network" "private_network" {
#   provider = google-beta
#   name     = local.private_network_name
# }

# # Reserve global internal address range for the peering
# resource "google_compute_global_address" "private_ip_address" {
#   provider      = google-beta
#   name          = local.private_ip_name
#   purpose       = "VPC_PEERING"
#   address_type  = "INTERNAL"
#   prefix_length = 16
#   network       = google_compute_network.private_network.self_link
# }

# # Establish VPC network peering connection using the reserved address range
# resource "google_service_networking_connection" "private_vpc_connection" {
#   provider                = google-beta
#   network                 = google_compute_network.private_network.self_link
#   service                 = "servicenetworking.googleapis.com"
#   reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
# }

# # ------------------------------------------------------------------------------
# # CREATE DATABASE INSTANCE WITH PRIVATE IP
# # ------------------------------------------------------------------------------

# module "postgres" {
#   # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
#   # to a specific version of the modules, such as the following example:
#   # source = "github.com/gruntwork-io/terraform-google-sql.git//modules/cloud-sql?ref=v0.2.0"
#   source = "../../modules/cloud-sql"

#   project = var.project
#   region  = var.region
#   name    = local.instance_name
#   db_name = var.db_name

#   engine       = var.postgres_version
#   machine_type = var.machine_type

#   # To make it easier to test this example, we are disabling deletion protection so we can destroy the databases
#   # during the tests. By default, we recommend setting deletion_protection to true, to ensure database instances are
#   # not inadvertently destroyed.
#   deletion_protection = false

#   # These together will construct the master_user privileges, i.e.
#   # 'master_user_name'@'master_user_host' IDENTIFIED BY 'master_user_password'.
#   # These should typically be set as the environment variable TF_VAR_master_user_password, etc.
#   # so you don't check these into source control."
#   master_user_password = var.master_user_password

#   master_user_name = var.master_user_name
#   master_user_host = "%"

#   # Pass the private network link to the module
#   private_network = google_compute_network.private_network.self_link

#   # Wait for the vpc connection to complete
#   dependencies = [google_service_networking_connection.private_vpc_connection.network]

#   custom_labels = {
#     test-id = "postgres-private-ip-example"
#   }
# }

# module "sql_cloud-sql" {
#   source  = "gruntwork-io/sql/google//modules/cloud-sql"
#   version = "0.6.0"
#   db_name="private-db"
#   private_network=

#   # insert the 13 required variables here
# }