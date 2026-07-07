terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=7.39.0"
    }
  }
}

data "google_project" "current" {
}
