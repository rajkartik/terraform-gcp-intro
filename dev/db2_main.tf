
# resource "google_compute_global_address" "service_range" {
#   name          = "address"
#   project       = var.project_id
#   purpose       = "VPC_PEERING"
#   address_type  = "INTERNAL"
#   prefix_length = 16
#   network       = module.vpc.network.self_link
# }

# resource "google_service_networking_connection" "private_service_connection" {
#   network                 = module.vpc.network.self_link
#   service                 = "servicenetworking.googleapis.com"
#   reserved_peering_ranges = [google_compute_global_address.service_range.name]
# }
# resource "google_sql_database_instance" "default" {
#   name                = var.postgresl_name
#   project             = var.project_id
#   database_version    = var.postgresql_version
#   deletion_protection = local.postgresql_deletion_protection
#   region              = var.region

#   # ! Warning
#   # The next TFSEC issues are not ignored, just added here as tfsec are not able
#   # to check they are enabled because of the dynamic database_flags block
#   #
#   #tfsec:ignore:google-sql-pg-log-checkpoints
#   #tfsec:ignore:google-sql-pg-log-connections
#   #tfsec:ignore:google-sql-pg-log-disconnections
#   #tfsec:ignore:google-sql-pg-log-lock-waits
#   settings {
#     # disk_autoresize   = var.postgresql_disk_autoresize
#     # disk_size         = var.postgresql_disk_size_gb
#     # disk_type         = var.production_mode ? "PD_SSD" : "PD_HDD"
#     # tier              = var.postgresql_tier
#     # availability_type = local.postgresql_availability_type

#     # user_labels = {
#     #   "owner" = "product"
#     # }

#     dynamic "database_flags" {
#       for_each = {
#         log_checkpoints    = "on"
#         log_connections    = "on"
#         log_disconnections = "on"
#         log_lock_waits     = "on"
#         log_temp_files     = "0"
#       }
#       iterator = flag

#       content {
#         name  = flag.key
#         value = flag.value
#       }
#     }

#     ip_configuration {
#       # Necessary to connect via Unix sockets
#       # https://cloud.google.com/sql/docs/mysql/connect-run#connecting_to
#       #tfsec:ignore:google-sql-no-public-access
#       ipv4_enabled    = true
#       private_network = module.vpc.network.self_link
#       #tfsec:ignore:google-sql-encrypt-in-transit-data
#       require_ssl = false
#     }

#     location_preference {
#       zone = var.zone
#     }

#     maintenance_window {
#       day          = local.postgreql_maintenance_window.day
#       hour         = local.postgreql_maintenance_window.hour
#       update_track = local.postgreql_maintenance_window.update_track
#     }

#     backup_configuration {
#       enabled                        = local.postgreql_backup_configuration.enabled
#       point_in_time_recovery_enabled = local.postgreql_backup_configuration.pitr_enabled
#       backup_retention_settings {
#         retained_backups = 30
#       }
#     }

#     insights_config {
#       query_insights_enabled  = true
#       query_string_length     = 1024
#       record_application_tags = false
#       record_client_address   = true
#     }
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }
