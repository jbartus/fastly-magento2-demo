provider "google" {
  project     = "se-development-9566"
  region      = "us-central1"
  zone        = "us-central1-c"
}

resource "google_compute_instance" "jbartus-tfdemo" {
    name = "jbartus-tfdemo"
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
    tags = [ "http-server" ]
    metadata_startup_script = "apt -y install nginx"
}