# terraform-google-compute-vm

Terraform module to create a Google Compute Engine Engine with meaningful defaults.

This module uses the [google](https://registry.terraform.io/providers/hashicorp/google) provider.

## Usage

```hcl
module "vm" {
  source            = "iqz-systems/compute-vm/google"
  version           = "1.1.5"

  providers = {
    google = google
  }
  project_region = "us-east1"
  project_zone   = "us-east1-b"
  instance_name  = "vm-2"
  instance_zone  = "us-east1-b"
  machine_type   = "e2-standard-4"
  boot_disk_size = 50
  instance_image = {
    family  = "ubuntu-minimal-2004-lts"
    project = "ubuntu-os-cloud"
  }
  service_account_email = "vm-sa"
  network_name          = "mynetwork"
  subnetwork_name       = "mysubnetwork"
  network_tags = [
    "http-server",
    "https-server",
    "vnc",
    "http",
    "https",
    "ssh",
  ]
  labels = {
    app = "my-app"
  }
  resource_policies = ["name-resource-policy"]
}
```

## Links

- [Terraform registry](https://registry.terraform.io/modules/iqz-systems/compute-vm/google/latest)
