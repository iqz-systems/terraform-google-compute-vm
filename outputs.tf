output "instance_name" {
  value       = google_compute_instance.instance.name
  description = "The name of the created vm instance."
}

output "instance_ip" {
  value       = one(google_compute_instance.instance.network_interface[0].access_config[*].nat_ip)
  description = "The external IP address of the vm (static or ephemeral), or null if it has no external IP."
}
