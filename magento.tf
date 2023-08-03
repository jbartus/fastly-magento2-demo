#######################################################################
## setup magento
## 
## this can't just run inside the google_compute_instance resource
## because it would create a circular dependency:
## the magento config script needs the fastly service id
## the fastly service needs the gcp vms nat ip (for origin)
## so terraform creates the fastly service *after* the gcp vm
## so the vm init script cant reference the service id
#######################################################################

resource "terraform_data" "magento_setup" {
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/id_rsa")
    host        = google_compute_instance.demo_origin_instance.network_interface.0.access_config.0.nat_ip
  }

  provisioner "remote-exec" {
    inline = [
      # wait until everything is installed
      "until grep -q 'startup-script exit status 0' /var/log/syslog; do sleep 30; done",
      "chmod +x /usr/local/bin/magento.sh",
      "su -c \"repo_user=${var.magento_pub_key} repo_pass=${var.magento_priv_key} base_url='${var.site_name}.global.ssl.fastly.net' service_id=${fastly_service_vcl.demo_service.id} api_key=${var.api_key} /usr/local/bin/magento.sh\" - magento_user"
    ]
  }
  # wait for the waf to be done so the magento plugin's vcl activation doesn't step on it
  depends_on = [sigsci_edge_deployment_service.ngwaf_edge_demo_link]
}