#######################################################################
## a VM on GCP to serve as the origin webserver
#######################################################################

resource "google_compute_instance" "demo_origin_instance" {
  name         = "${var.site_name}-origin"
  machine_type = "n2-standard-4"
  zone         = "us-west1-a"
  tags         = ["https-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2304-amd64"
    }
  }

  # give it a public IP
  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = "ubuntu:${file("${var.ssh_pub_key}")}"
  }

  # configure a minmial secure webserver
  metadata_startup_script = "apt update && apt -y install apache2 && a2enmod ssl && a2ensite default-ssl && a2dissite 000-default && service apache2 restart && usermod -a -G www-data ubuntu"
}