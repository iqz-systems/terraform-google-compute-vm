output "instance_name" {
  value       = google_compute_instance.instance.name
  description = "The name of the created vm instance."
}

output "instance_ip" {
  value       = google_compute_address.instance_ip.address
  description = "The IP address of the vm."
}
