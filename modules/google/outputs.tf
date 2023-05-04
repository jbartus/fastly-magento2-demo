output "origin_ip" {
  description = "external ip of a vm to use as origin"
  value       = google_compute_instance.demo_origin_instance.network_interface.0.access_config.0.nat_ip
}