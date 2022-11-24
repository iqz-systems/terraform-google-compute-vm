terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=4.11.0"
    }
  }
}

data "google_project" "current" {
}
