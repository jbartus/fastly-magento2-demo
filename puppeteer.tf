resource "google_compute_instance" "puppeteer" {
  count                     = var.puppeteer == true ? 1 : 0
  name                      = "${var.site_name}-puppeteer"
  machine_type              = "c3-standard-4"
  depends_on                = [fastly_service_vcl.demo_service, terraform_data.magento_setup]
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2310-amd64"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = "ubuntu:${file("${var.ssh_pub_key}")}"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${var.ssh_priv_key}")
    host        = self.network_interface.0.access_config.0.nat_ip
  }

  provisioner "file" {
    source      = "puppets/"
    destination = "/home/ubuntu"
  }

  provisioner "file" {
    source      = "puppeteer.sh"
    destination = "puppeteer.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x puppeteer.sh",
      "url=${var.site_name}.freetls.fastly.net ./puppeteer.sh"
    ]
  }
}