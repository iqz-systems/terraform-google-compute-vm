# terraform-google-compute-vm

Terraform module to create a Google Compute Engine instance with meaningful defaults.

This module uses the [google](https://registry.terraform.io/providers/hashicorp/google) provider (`>= 7.39.0`). The project is inferred from the configured provider, so no project variable is required.

Secure defaults are always applied to the instance: OS Login is enabled (`enable-oslogin = TRUE`), project-wide SSH keys are blocked (`block-project-ssh-keys = TRUE`), and the attached service account is granted the `cloud-platform` scope.

## Usage

```hcl
module "vm" {
  source  = "iqz-systems/compute-vm/google"
  version = "5.0.0"

  providers = {
    google = google
  }

  project_region = "us-east1"
  instance_name  = "vm-2"
  instance_zone  = "us-east1-b"
  machine_type   = "e2-standard-4"

  # Boot disk: provide either instance_image or source_disk (not both).
  boot_disk_size = 50
  instance_image = {
    family  = "ubuntu-minimal-2004-lts"
    project = "ubuntu-os-cloud"
  }

  service_account_email = "vm-sa@my-project.iam.gserviceaccount.com"

  network_name    = "mynetwork"
  subnetwork_name = "mysubnetwork"
  network_tags = [
    "http-server",
    "https-server",
    "ssh",
  ]
  labels = {
    app = "my-app"
  }

  # Networking: no external IP by default.
  # assign_external_ip = true   # attach an ephemeral external IP
  # create_static_ip   = true   # reserve a static external IP (implies assign_external_ip)

  resource_policies = ["name-resource-policy"]
}
```

### Boot disk

Provide **exactly one** of:

- `instance_image` - looks up an image by `family`/`project` and creates a new boot disk. Subsequent image-family updates are ignored (`lifecycle.ignore_changes`) so a new image release does not force the instance to be recreated.
- `source_disk` - boots from an existing disk or disk image. To boot from a snapshot, first create a `google_compute_disk` from the snapshot and pass its name or `self_link` here.

### External IP

External IP assignment is opt-in and controlled by two independent flags:

| `assign_external_ip` | `create_static_ip` | Result                                   |
| -------------------- | ------------------ | ---------------------------------------- |
| `false` (default)    | `false` (default)  | No external IP (internal only)           |
| `true`               | `false`            | Ephemeral external IP assigned by GCP    |
| any                  | `true`             | Reserved static (regional) external IP   |

The `instance_ip` output reflects the actual assigned address (static or ephemeral), or `null` when the instance has no external IP.

## Inputs

| Name                      | Type                                   | Default      | Required | Description                                                                 |
| ------------------------- | -------------------------------------- | ------------ | :------: | --------------------------------------------------------------------------- |
| `project_region`          | `string`                               | -            |   yes    | The region where the resources will be created.                             |
| `instance_name`           | `string`                               | -            |   yes    | The name of the instance to be created.                                     |
| `instance_zone`           | `string`                               | -            |   yes    | The zone in which the machine has to be created.                            |
| `machine_type`            | `string`                               | `"e2-small"` |    no    | The machine type. See [machine types](https://cloud.google.com/compute/docs/machine-types). |
| `boot_disk_size`          | `number`                               | `20`         |    no    | Size in GB for the boot disk.                                               |
| `instance_image`          | `object({ family, project })`          | `null`       |    no    | OS image to create the boot disk from. Provide this or `source_disk`.       |
| `source_disk`             | `string`                               | `null`       |    no    | Existing disk name or `self_link` to boot from. Provide this or `instance_image`. |
| `service_account_email`   | `string`                               | -            |   yes    | Email of the service account associated with the instance.                  |
| `service_account_scopes`  | `list(string)`                         | `[]`         |    no    | Additional scopes appended to the default `cloud-platform` scope.           |
| `network_name`            | `string`                               | `"default"`  |    no    | The network to associate the VM with.                                       |
| `subnetwork_name`         | `string`                               | `"default"`  |    no    | The subnetwork to associate the VM with.                                    |
| `subnetwork_project`      | `string`                               | `""`         |    no    | The project the subnetwork belongs to.                                      |
| `network_tags`            | `list(string)`                         | -            |   yes    | Network tags attached to the instance.                                      |
| `labels`                  | `map(string)`                          | -            |   yes    | Labels associated with the instance.                                        |
| `resource_policies`       | `list(string)`                         | `[]`         |    no    | Resource policies associated with the instance.                             |
| `metadata_startup_script` | `string`                               | `null`       |    no    | Startup script injected into the VM.                                        |
| `assign_external_ip`      | `bool`                                 | `false`      |    no    | Give the instance an external IP (ephemeral unless `create_static_ip`).     |
| `create_static_ip`        | `bool`                                 | `false`      |    no    | Reserve a static regional external IP. Implies `assign_external_ip`.        |

## Outputs

| Name            | Description                                                                    |
| --------------- | ------------------------------------------------------------------------------ |
| `instance_name` | The name of the created VM instance.                                           |
| `instance_ip`   | The external IP (static or ephemeral), or `null` if the instance has none.     |

## Links

- [Terraform registry](https://registry.terraform.io/modules/iqz-systems/compute-vm/google/latest)
