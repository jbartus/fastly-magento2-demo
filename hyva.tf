#######################################################################
## setup hyva theme
#######################################################################

resource "terraform_data" "hyva_setup" {
  count      = var.hyva == true ? 1 : 0
  depends_on = [terraform_data.magento_setup]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${var.ssh_priv_key}")
    host        = google_compute_instance.demo_origin_instance.network_interface.0.access_config.0.nat_ip
  }

  provisioner "file" {
    source      = "hyva.sh"
    destination = "hyva.sh"
  }

  provisioner "file" {
    source      = var.hyva_ssh_priv_key
    destination = ".ssh/id_rsa"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x hyva.sh",
      "chmod 600 ~/.ssh/id_rsa",
      "./hyva.sh"
    ]
  }
}