# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a published Terraform module (`iqz-systems/compute-vm/google` on the Terraform Registry) that provisions a single Google Compute Engine instance with opinionated defaults. It is a library module, not a root configuration - there is no `provider` block, backend, or `.tfvars` here; consumers pass a `google` provider in and supply variables.

## Commands

```bash
terraform init          # download the hashicorp/google provider (>=7.39.0)
terraform fmt -check     # verify formatting; run `terraform fmt` to fix
terraform validate       # validate syntax and internal consistency
```

There is no test suite and no CI in the repo. `terraform plan`/`apply` cannot run standalone because required variables (e.g. `service_account_email`) have no defaults and there is no provider configuration - validation happens from a consuming root module.

## Architecture

Files are split by concern (Terraform loads all `.tf` files in the directory regardless of name):

- `main.tf` - provider requirements and the `data "google_project" "current"` lookup used to resolve `project_id` everywhere.
- `variables.tf` - all input variables.
- `vm.tf` - the resources: optional external/static IP address, optional image lookup, and the `google_compute_instance`.
- `outputs.tf` - exported `instance_name` and `instance_ip`.

### Key design decisions

- **Project is never passed as a variable.** It is always read from `data.google_project.current.project_id` (the project of the injected provider).
- **Two mutually exclusive ways to define the boot disk:** `instance_image` (looked up via `data.google_compute_image`, count-gated on non-null) OR `source_disk` (an existing disk/snapshot-derived disk). Exactly one should be set. The `initialize_params` block is a `dynamic` block that only renders when `instance_image` is provided.
- **Image drift is intentionally ignored.** `lifecycle.ignore_changes` on `boot_disk[0].initialize_params[0].image` prevents plans from wanting to rebuild the instance when the image family publishes a new version.
- **External IP is opt-in and decoupled from static reservation.** Two variables (both default `false`): `assign_external_ip` controls whether the instance has an external IP at all; `create_static_ip` additionally reserves a `google_compute_address`. The `access_config` dynamic block renders when `assign_external_ip || create_static_ip` (so setting only `create_static_ip` still yields an external IP). `nat_ip` is set to the reserved address only when `create_static_ip`; otherwise it is left empty and GCP assigns an ephemeral IP. The `instance_ip` output reads the actual assigned IP back off the instance's `access_config`, so it covers both static and ephemeral (and is `null` when there is no external IP).
- **Security defaults are hardcoded in metadata:** `enable-oslogin = TRUE` and `block-project-ssh-keys = TRUE`. The service account always gets the `cloud-platform` scope, with `service_account_scopes` appended via `concat`.
- `allow_stopping_for_update = true` lets Terraform stop the VM to apply changes that require it (e.g. machine type).

## Conventions

- 2-space indentation, LF, final newline, trailing whitespace trimmed (enforced by `.editorconfig`; Markdown uses 4-space indent).
- Do not use em-dashes in any output or committed content.
- This module is published and versioned via SemVer git tags (`vX.Y.Z`; latest is the `v4.x` line). Releases happen off tags, not this file. `README.md` documents the full input/output surface (usage example + tables) and is user-facing - keep it in sync when the variable/output surface changes, and bump the example version: minor for additive changes, major for breaking ones.
