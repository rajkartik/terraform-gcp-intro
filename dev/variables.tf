variable "region" {
  type        = string
  description = "Default region to use for the project"
  default     = "europe-west1"
}
variable "subnet_gke" {
  type        = string
  description = "Default zone to use for MIG runner deployment"
  default     = "gke-subnet"
}
variable "zone" {
  type        = string
  description = "Default zone to use for MIG runner deployment"
  default     = "europe-west1-b"
}
variable "project_id" {
  type        = string
  description = "Default zone to use for MIG runner deployment"
  default     = "automategcp"
}
variable "authorized_networks" {
  description = "Map of NAME=>CIDR_RANGE to allow to connect to the database(s)."
  type        = map(string)
  default     = null
}
# variable "name_prefix" {
#   description = "The name prefix for the database instance. Will be appended with a random string. Use lowercase letters, numbers, and hyphens. Start with a letter."
#   type        = string
# }

# variable "master_user_name" {
#   description = "The username part for the default user credentials, i.e. 'master_user_name'@'master_user_host' IDENTIFIED BY 'master_user_password'. This should typically be set as the environment variable TF_VAR_master_user_name so you don't check it into source control."
#   type        = string
# }

# variable "master_user_password" {
#   description = "The password part for the default user credentials, i.e. 'master_user_name'@'master_user_host' IDENTIFIED BY 'master_user_password'. This should typically be set as the environment variable TF_VAR_master_user_password so you don't check it into source control."
#   type        = string
# }

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# Generally, these values won't need to be changed.
# ---------------------------------------------------------------------------------------------------------------------

# variable "postgres_version" {
#   description = "The engine version of the database, e.g. `POSTGRES_9_6`. See https://cloud.google.com/sql/docs/db-versions for supported versions."
#   type        = string
#   default     = "POSTGRES_13_6"
# }

# variable "machine_type" {
#   description = "The machine type to use, see https://cloud.google.com/sql/pricing for more details"
#   type        = string
#   default     = "db-f1-micro"
# }

# variable "db_name" {
#   description = "Name for the db"
#   type        = string
#   default     = "default"
# }

# variable "name_override" {
#   description = "You may optionally override the name_prefix + random string by specifying an override"
#   type        = string
#   default     = null
# }
variable "network_name1" {
   description = "network name"
  type        = string
  default     = "my-network-module"
  
}
