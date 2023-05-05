resource "google_compute_instance" "demo_origin_instance" {
  name         = "${var.site_name}-origin"
  machine_type = "e2-medium"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = "default"
    access_config {}
  }
  tags                    = ["http-server"]
  metadata_startup_script = file("${path.module}/init.sh")
}