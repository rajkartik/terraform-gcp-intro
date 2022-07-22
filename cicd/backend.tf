terraform {
  backend "gcs" {
    bucket = "mydev-states-climate"
    prefix = "cicd"
  }
}