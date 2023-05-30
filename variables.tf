variable "project_region" {
  type        = string
  description = "The region where the resources will be created."
}

variable "project_zone" {
  type        = string
  description = "The zone where the resources will be created."
}

variable "instance_name" {
  type        = string
  description = "The name of the instance to be created."
}

variable "instance_zone" {
  type        = string
  description = "The zone in which the machine has to be created."
}

variable "machine_type" {
  type        = string
  default     = "e2-small"
  description = "The type of the machine to create. See https://cloud.google.com/compute/docs/machine-types."
}

variable "boot_disk_size" {
  type        = number
  default     = 20
  description = "The size in GB for the boot disk to be used for the instance."
}

variable "instance_image" {
  type = object({
    family  = string
    project = string
  })
  description = "The OS image details of the instance. See https://cloud.google.com/compute/docs/images/os-details#general-info."
  default = {
    family  = "ubuntu-minimal-2004-lts"
    project = "ubuntu-os-cloud"
  }
}

variable "service_account_email" {
  type        = string
  description = "The email of the service account that will be associated with this instance."
}

variable "network_name" {
  type        = string
  default     = "default"
  description = "The network name to associate this vm with."
}

variable "subnetwork_name" {
  type        = string
  default     = "default"
  description = "The sub-network name to associate this vm with."
}

variable "subnetwork_project" {
  type        = string
  default     = ""
  description = "The project in which the subnetwork belongs."
}

variable "network_tags" {
  type        = list(string)
  description = "A list of network tags to be attached to the instance."
}

variable "labels" {
  type        = map(string)
  description = "A map of labels to be associated with the instance."
}
