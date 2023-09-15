#######################################################################
## setup magento
#######################################################################

resource "terraform_data" "magento_setup" {
  count = var.magento == true ? 1 : 0

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = google_compute_instance.demo_origin_instance.network_interface.0.access_config.0.nat_ip
  }

  provisioner "file" {
    source      = "magento.sh"
    destination = "magento.sh"
  }

  provisioner "file" {
    source      = "fastly-magento-module.sh"
    destination = "fastly-magento-module.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "until grep -q 'startup-script exit status 0' /var/log/syslog; do sleep 10; done",
      "sudo usermod -a -G www-data ubuntu"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x magento.sh fastly-magento-module.sh",
      "repo_user=${var.magento_pub_key} repo_pass=${var.magento_priv_key} base_url='${var.site_name}.freetls.fastly.net' ./magento.sh",
      "service_id=${fastly_service_vcl.demo_service.id} api_key=${var.fastly_api_key} ./fastly-magento-module.sh"
    ]
  }
}