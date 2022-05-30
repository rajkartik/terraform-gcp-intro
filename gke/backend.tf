terraform {
  backend "gcs" {
    bucket = "devopscube-states"
    prefix = "demo"
  }
}