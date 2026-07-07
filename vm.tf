resource "google_compute_address" "instance_ip" {
  count = var.create_static_ip ? 1 : 0

  name    = "${var.instance_name}-ip"
  project = data.google_project.current.project_id
  region  = var.project_region
}

data "google_compute_image" "instance_image" {
  count = var.instance_image != null ? 1 : 0

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
    dynamic "initialize_params" {
      for_each = var.instance_image != null ? [1] : []
      content {
        image = var.instance_image != null ? data.google_compute_image.instance_image.0.self_link : null
        size  = var.boot_disk_size
      }
    }
    source = var.source_disk
  }

  network_interface {
    network            = var.network_name
    subnetwork         = var.subnetwork_name
    subnetwork_project = var.subnetwork_project

    dynamic "access_config" {
      for_each = (var.assign_external_ip || var.create_static_ip) ? [1] : []
      content {
        nat_ip = var.create_static_ip ? google_compute_address.instance_ip.0.address : null
      }
    }
  }

  metadata = {
    enable-oslogin         = "TRUE"
    block-project-ssh-keys = "TRUE"
  }

  metadata_startup_script = var.metadata_startup_script

  labels = var.labels

  allow_stopping_for_update = true

  service_account {
    email  = var.service_account_email
    scopes = concat(["cloud-platform"], var.service_account_scopes)
  }

  lifecycle {
    ignore_changes = [
      boot_disk[0].initialize_params[0].image,
    ]
  }
  resource_policies = var.resource_policies
}
