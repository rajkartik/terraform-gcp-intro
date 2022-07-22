module "vpc" {
  source     = "../modules/net-vpc"
  project_id = var.project_id
  name       = "my-network-module"
  psa_config = {
    ranges = { cloud-sql = "/16"
     }
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
    "servicenetworking.googleapis.com",
    "secretmanager.googleapis.com",
    "iap.googleapis.com"

  ])

  service = each.key

  project            = var.project_id
  disable_on_destroy = false
}
module "db" {
  count  =1
  source           = "../modules/cloudsql-instance"
  project_id       = var.project_id
  network          = module.vpc.network.self_link
  name             = "samp1-priv-db-4"
  region           = "europe-west1"
  database_version = "POSTGRES_13"
  tier             = "db-g1-small"
  
  availability_type = "REGIONAL"

 authorized_networks = {
    
    name="gke-master"
    value="172.16.0.32/28"
    
    
    }
  databases = [
    "my-db-1"
  ]

  users = {
    # generatea password for user1
    "admin" = null
    # assign a password to user2
    user1  = "mypassword"
  }




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
module "cluster_1" {
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

data "google_client_config" "default" {
  provider = google
}
data "google_client_config" "default1" {
  provider = google-beta
}

provider "kubernetes" {
  host                   = "https://${module.cluster_1.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.cluster_1.ca_certificate)
}
# resource "kubernetes_namespace" "awesome-namespace" {

#   #  depends_on = [
#   #   module.cluster_1,google_client_config.default
#   # ]

#  metadata {
#    name = "awesome-namespace"
#  }
# }

# resource "kubernetes_namespace" "prod" {
#   metadata {
#     annotations = {
#       name = "my-namespace"
#     }

#     labels = {
#       namespace = "demo_name"
#     }

#     name = "demname"
#   }
#   # depends_on = [
#   #   module.cluster_1,google_client_config.default
#   # ]
# }
module "nat" {
  source         = "../modules/net-cloudnat"
  project_id     = var.project_id
  region         = "europe-west1"
  name           = "internet-access"
  router_network = module.vpc.network.self_link
}

module "bucket" {
  source     = "../modules/gcs"
  project_id = var.project_id
  prefix     = "test"
  name       = "automate-gcs-rox-01"
  cors = {

    origin = ["*"]

    method = ["GET", "PUT", "POST", ]

    response_header = [

      "Content-Type",

      "Content-MD5",

      "Content-Disposition",

      "Cache-Control",

      "x-goog-content-length-range",

      "x-goog-meta-filename"

    ]

    max_age_seconds = 3600

  }



  iam = {
    "roles/storage.admin" = ["serviceAccount:858144231994@cloudbuild.gserviceaccount.com"]
  }

}
# output "password" {
#   sensitive = true
#   value = module.db.user_passwords
# }
# module "bigquery-dataset" {

#   source     = "../modules/bigquery-dataset"
#   project_id = var.project_id
#   id          = "my_samp_dataset"
#   friendly_name = "mydata"
#   access = {
#     dataEditor   = { role = "roles/bigquery.dataEditor", type = "user" }
#     owner          = { role = "OWNER", type = "user" }
#     #project_owners = { role = "OWNER", type = "special_group" }
#     #view_1         = { role = "READER", type = "view" }
#   }
#   access_identities = {
#     dataEditor   = "858144231994@cloudbuild.gserviceaccount.com"
#     dataEditor2 ="858144231994-compute@developer.gserviceaccount.com"
#     owner          = "rajkartik098@gmail.com"
#     #project_owners = "projectOwners"
#     #view_1         = "my-project|my-dataset|my-table"
#   }
# }
module "glb" {

  source     = "../modules/net-glb"
  name       = "glb-test"
  project_id = var.project_id
  reserve_ip_address=true
  
     url_map_config = {
    default_service      =  "my-bucket-backend"
    default_route_action = null
    default_url_redirect = null
    
    
    tests                = null
    header_action        = null
    host_rules           = [

   {
    hosts        = ["mysite2.com"]
    path_matcher = "mysite"
  }
    ]
    path_matchers = [
      {
        name = "mysite"
        path_rules = [
          {
            paths   = ["/*"]
            service = "my-bucket-backend"
          }
        ]
      }
    ]
  }
  #  url_map_config = {
  #   default_service      = "my-bucket-backend"
  #   default_route_action = null
  #   default_url_redirect = {strip_query=true}
  #   tests = []
  #   header_action = null
  #   host_rules           = [
  #     {
  #     path_matcher="mysite"
  #   hosts="my-example.com"}]
  #   path_matchers = [
  #     {
  #       name = "mysite"
  #       path_rules = [
  #         {
  #           paths   = ["/*"]
  #           service = "my-bucket-backend"
  #         }
  #       ]
  #     }
  #   ]
  # }
  #url_map_config = google_compute_url_map.urlmap

# global_forwarding_rule_config = {
#     load_balancing_scheme = "EXTERNAL"
#     ip_protocol           = "TCP"
#     ip_version            = "IPV6"
#     # If not specified, 80 for https = false, 443 otherwise
#     port_range = null
#   }

  backend_services_config = {
    my-bucket-backend = {
      bucket_config = {
        bucket_name = "test-automate-gcs-rox-01"
        options     = null
      }
      group_config = null
      enable_cdn   = true
      cdn_config   =      ( {cache_mode  = "Cache static content"
      client_ttl                   = 60
      default_ttl                  = 60
      max_ttl                      = 24*60
      negative_caching             = null
      negative_caching_policy      = {}
      serve_while_stale            = true
      signed_url_cache_max_age_sec = null
    }
      )
    }
  }
}




module "firewall" {
  source              = "../modules/net-vpc-firewall"
  project_id          = var.project_id
  network             = module.vpc.network.self_link
  admin_ranges        = []
  http_source_ranges  = []
  https_source_ranges = []
  ssh_source_ranges   = []
  custom_rules = {
    allow-https = {
      description          = "Allow HTTPS networks."
      direction            = "INGRESS"
      action               = "allow"
      sources              = []
      ranges               = ["0.0.0.0/0"]
      targets              = []
      use_service_accounts = false
      rules                = [{ protocol = "tcp", ports = [80,443] }]
      extra_attributes     = {}
    }
  }
}


module "secret-manager" {
  source     = "../modules/secret-manager"
  project_id = var.project_id
  secrets    = {
    client_app_mybox_www   = null
    test-manual-api = null
  }
  labels={
    client_app_mybox_www = { group = "group-capp-ci-dev-${local.s_grps[0]}"},
    test-manual-api = { group = "group-capp-ci-dev-${local.s_grps[1]}"}
    }


  
  versions = {
    client_app_mybox_www = {
      v1 = { enabled = false, data = "auto foo bar baz" }
      v2 = { enabled = true, data = "auto foo bar spam" }
    },
    test-manual-api = {
      v1 = { enabled = true, data = "manual foo bar spam" }
    }
  }
  depends_on = [
    google_project_service.service
  ]
}

module "container_registry" {
  source     = "../modules/container-registry"
  project_id = var.project_id
  location   = "EU"
  iam = {
    "roles/storage.admin" = ["serviceAccount:858144231994@cloudbuild.gserviceaccount.com"]
  }
}



module "my_service_account" {
  source       = "../modules/iam-service-account"
  project_id   = var.project_id
  name         = "my-sa-dev"
  generate_key = true

  iam_project_roles = {
    "${var.project_id}" = [
      "roles/cloudsql.client",
      "roles/iam.serviceAccountTokenCreator",
      "roles/pubsub.editor",
      "roles/container.admin"

    ]
  }

}


# resource "google_service_account" "workload_identity_sa" {
#   project      = local.project_id
#   account_id   = "workload-identity-iam-sa"
#   display_name = "A service account to be used by GKE Workload Identity"
# }

# Binding between IAM SA and Kubernetes SA
resource "google_service_account_iam_binding" "gke_iam_binding" {
  service_account_id = module.my_service_account.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    # "serviceAccount:<PROJECT_ID>.svc.id.goog[<KUBERNETES_NAMESPACE>/<HELM_PACKAGE_INSTALLED_NAME>-common-backend]"
    "serviceAccount:${var.project_id}.svc.id.goog[cart/carto-common-backend]",
  ]
}







module "bastion_vm_gke" {
  source = "terraform-google-modules/bastion-host/google"

  project = var.project_id
  network = module.vpc.network.self_link
  subnet  = module.vpc.subnet_self_links["${var.region}/${var.subnet_gke}"]
  zone    = var.zone
  #service_account_email = module.my_service_account.email
  # depends_on = [
  #   module.climate-engine-service-account
  # ]
  depends_on = [module.vpc.psa_config,
    google_project_service.service
  ]
  members = ["serviceAccount:${module.my_service_account.email}"]

}




















# output "backe" {
#   value = module.glb.backend_services.bucket["my-bucket-backend"].id
# }

# resource "google_compute_url_map" "urlmap" {
#   name="url map"
  
#   default_service = module.glb.backend_services.bucket["my-bucket-backend"].id

#   host_rule {
#     hosts        = ["mysite.com"]
#     path_matcher = "mysite"
#   }


#   path_matcher {
#     name            = "mysite"
#     default_service = module.glb.backend_services.bucket["my-bucket-backend"].id

#     path_rule {
#       paths   = ["/*"]
#       service = module.glb.backend_services.bucket["my-bucket-backend"].id
#     }


#   }


# }


