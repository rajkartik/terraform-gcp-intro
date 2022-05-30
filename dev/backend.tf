terraform {
  backend "gcs" {
    bucket = "mydev-states-climate"
    prefix = "demo/dev"
  }
}