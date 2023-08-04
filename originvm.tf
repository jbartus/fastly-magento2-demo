#######################################################################
## a linux VM on GCP to serve as the origin webserver
#######################################################################

resource "google_compute_instance" "demo_origin_instance" {
  name         = "${var.site_name}-origin"
  machine_type = "n2-standard-4"
  zone         = "us-west1-a"
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2304-amd64"
    }
  }
  network_interface {
    network = "default"
    # default access_config for a public ip
    access_config {}
  }
  # by default gcp projects have firewall rules
  # that permit 443 to instances with this tag
  tags = ["https-server"]
  # do all the server setup steps done by root
  metadata_startup_script = file("vm-init.sh")
  # pre-place the magento script now as the 'file' provisioner
  # doesnt work in terraform_data resources (used later)
  metadata = {
    ssh-keys = "root:${file("${var.ssh_pub_key}")}"
  }
  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "root"
      private_key = file("${var.ssh_priv_key}")
      host        = self.network_interface.0.access_config.0.nat_ip
    }
    source      = "magento.sh"
    destination = "/usr/local/bin/magento.sh"
  }
}