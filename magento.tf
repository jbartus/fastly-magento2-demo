#######################################################################
## setup magento
#######################################################################

resource "terraform_data" "magento_setup" {
  # wait for the waf to be done so the magento plugin's vcl activation doesn't step on it
  depends_on = [sigsci_edge_deployment_service.ngwaf_edge_demo_link]

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

  provisioner "remote-exec" {
    inline = [
      "chmod +x magento.sh",
      "repo_user=${var.magento_pub_key} repo_pass=${var.magento_priv_key} base_url='${var.site_name}.freetls.fastly.net' service_id=${fastly_service_vcl.demo_service.id} api_key=${var.fastly_api_key} ./magento.sh"
    ]
  }
}