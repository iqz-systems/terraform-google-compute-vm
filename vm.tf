resource "google_compute_address" "instance_ip" {
  name    = "${var.instance_name}-ip"
  project = data.google_project.current.project_id
  region  = var.project_region
}

data "google_compute_image" "instance_image" {
  # https://cloud.google.com/compute/docs/images/os-details#ubuntu_lts
  family  = var.instance_image.family
  project = var.instance_image.project
}

resource "google_compute_instance" "instance" {
  name    = var.instance_name
  project = data.google_project.current.project_id

  machine_type = var.machine_type
  zone         = var.instance_zone

  tags = var.network_tags

  boot_disk {
    initialize_params {
      image = data.google_compute_image.instance_image.self_link
      size  = var.boot_disk_size
    }
  }

  network_interface {
    network            = var.network_name
    subnetwork         = var.subnetwork_name
    subnetwork_project = var.subnetwork_project


    access_config {
      nat_ip = google_compute_address.instance_ip.address
    }
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  labels = var.labels

  allow_stopping_for_update = true

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  lifecycle {
    ignore_changes = [
      boot_disk[0].initialize_params[0].image,
      boot_disk[0].initialize_params[0].size,
      metadata,
    ]
  }
  resource_policies = var.resource_policies
}
