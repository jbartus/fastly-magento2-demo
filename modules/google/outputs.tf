output "origin_ip" {
  description = "external ip of a vm to use as origin"
  value       = google_compute_instance.jbartus-tfdemo.network_interface.0.access_config.0.nat_ip
}