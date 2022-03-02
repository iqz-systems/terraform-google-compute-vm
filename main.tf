terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=4.11.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.project_region
  zone    = var.project_zone
}

data "google_project" "current" {
}
