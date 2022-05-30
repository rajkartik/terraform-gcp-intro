variable "region" {
  type        = string
  description = "Default region to use for the project"
  default     = "europe-north1"
}

variable "zone" {
  type        = string
  description = "Default zone to use for MIG runner deployment"
  default     = "europe-north1-b"
}
variable "project_id" {
  type        = string
  description = "Default zone to use for MIG runner deployment"
  default     = "automategcp"
}