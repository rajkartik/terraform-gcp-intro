resource "google_container_cluster" "gke_cluster" {
  description              = "GKE Cluster for personal projects"
  initial_node_count       = 1
  location                 = "europe-north1-b"
  name                     = "prod"
  network                  = google_compute_network.gke.self_link
  remove_default_node_pool = true
  subnetwork               = google_compute_subnetwork.gke.self_link

  ip_allocation_policy {
    cluster_secondary_range_name  = local.cluster_secondary_range_name
    services_secondary_range_name = local.services_secondary_range_name
  }
    depends_on = [
    google_project_service.service
  ]
}

resource "google_compute_network" "gke" {
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false
  description                     = "Compute Network for GKE nodes"
  name                            = "${terraform.workspace}-gke"
  routing_mode                    = "GLOBAL"
}

resource "google_compute_subnetwork" "gke" {
  name          = "prod-gke-subnetwork"
  ip_cidr_range = "10.255.0.0/16"
  region        = "europe-north1"
  network       = google_compute_network.gke.id

  secondary_ip_range {
    range_name    = local.cluster_secondary_range_name
    ip_cidr_range = "10.0.0.0/10"
  }

  secondary_ip_range {
    range_name    = local.services_secondary_range_name
    ip_cidr_range = "10.64.0.0/10"
  }
  depends_on = [
    google_project_service.service
  ]
}

locals {
  cluster_secondary_range_name  = "cluster-secondary-range"
  services_secondary_range_name = "services-secondary-range"
}

resource "google_container_node_pool" "gke_node_pool" {
  cluster    = google_container_cluster.gke_cluster.name
  location   = "europe-north1"
  name       = terraform.workspace
  node_count = 3
  
  node_locations = [
    "europe-north1-b"
  ]

  node_config {
    disk_size_gb    = 100
    disk_type       = "pd-standard"
    image_type      = "cos_containerd"
    local_ssd_count = 0
    machine_type    = "g1-small"
    preemptible     = false
    service_account = google_service_account.gke_node_pool.email
  }
}

resource "google_service_account" "gke_node_pool" {
  account_id   = "${terraform.workspace}-node-pool"
  description  = "The default service account for pods to use in ${terraform.workspace}"
  display_name = "GKE Node Pool ${terraform.workspace} Service Account"
}

resource "google_project_iam_member" "gke_node_pool" {
  member = "serviceAccount:${google_service_account.gke_node_pool.email}"
  role   = "roles/viewer"
}
resource "google_service_account" "sa-name" {
  account_id = "sa-name"
  display_name = "SA"
}

resource "google_project_iam_member" "firestore_owner_binding" {
  project = var.project_id
  role    = "roles/datastore.owner"
  member  = "serviceAccount:${google_service_account.sa-name.email}"
}
resource "google_project_service" "service" {
  for_each = toset([
    "compute.googleapis.com",
    "appengine.googleapis.com",
    "appengineflex.googleapis.com",
    "cloudbuild.googleapis.com",
    "container.googleapis.com"

  ])

  service = each.key

  project            = var.project_id
  disable_on_destroy = false
}