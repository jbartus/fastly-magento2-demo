#######################################################################
## a linux VM on GCP to serve as the origin webserver
#######################################################################

resource "google_compute_instance" "demo_origin_instance" {
  name         = "${var.site_name}-origin"
  machine_type = "c3-standard-4"
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2210-amd64"
    }
  }
  network_interface {
    network = "default"
    access_config {}
  }
  tags                    = ["http-server"]
  metadata_startup_script = file("vm-init.sh")
  metadata = {
    ssh-keys = "root:${file("~/.ssh/id_rsa.pub")}"
  }
  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "root"
      private_key = file("~/.ssh/id_rsa")
      host        = self.network_interface.0.access_config.0.nat_ip
    }
    source      = "magento.sh"
    destination = "/usr/local/bin/magento.sh"
  }
}

#######################################################################
## a fastly delivery service 
#######################################################################

resource "fastly_service_vcl" "demo_service" {
  name = var.site_name

  domain {
    name = "${var.site_name}.global.ssl.fastly.net"
  }

  backend {
    address = google_compute_instance.demo_origin_instance.network_interface.0.access_config.0.nat_ip
    name    = "${var.site_name}-origin"
    port    = 80
    shield  = "ewr-nj-us"
  }

  product_enablement {
    image_optimizer = true
  }

  force_destroy = true

  # example vcl snippets
  snippet {
    name    = "init"
    type    = "init"
    content = file("vcl/init.vcl")
  }

  snippet {
    name    = "recv"
    type    = "recv"
    content = file("vcl/recv.vcl")
  }

  snippet {
    name    = "error"
    type    = "error"
    content = file("vcl/error.vcl")
  }

  snippet {
    name    = "deliver"
    type    = "deliver"
    content = file("vcl/deliver.vcl")
  }

  # ignore most resources rather than spar with the ngwaf & magento plugin
  lifecycle {
    ignore_changes = [
      acl,
      condition,
      dictionary,
      dynamicsnippet,
      header,
      request_setting,
      snippet
    ]
  }
}

#######################################################################
## sigsci site and ngwaf@edge config 
#######################################################################

resource "sigsci_site" "demo_site" {
  display_name = var.site_name
  short_name   = var.site_name
  agent_level  = "block"
}

resource "sigsci_edge_deployment" "ngwaf_edge_demo" {
  site_short_name = sigsci_site.demo_site.short_name
}

resource "sigsci_edge_deployment_service" "ngwaf_edge_demo_link" {
  site_short_name  = sigsci_edge_deployment.ngwaf_edge_demo.site_short_name
  fastly_sid       = fastly_service_vcl.demo_service.id
  activate_version = true
  percent_enabled  = 100
}

#######################################################################
## setup magento
## 
## this needs to be its own dummy-resource + provisioner because
## the vcl service depends on the gcp vm ip as an origin, so terraform
## creates the vm first and the service second.  that means the service
## id doesn't exist yet when the vm init script runs.
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

#######################################################################
## example javascript compute@edge application 
#######################################################################

resource "terraform_data" "build_app" {
  provisioner "local-exec" {
    command = "cd edgeapp && npm install && fastly compute build"
  }
}

data "fastly_package_hash" "edgeapp" {
  filename = "edgeapp/pkg/edgeapp.tar.gz"
  depends_on = [ terraform_data.build_app ]
}

resource "fastly_service_compute" "demo" {
  name = "${var.site_name}-wasm"

  domain {
    name = "${var.site_name}.edgecompute.app"
  }

  package {
    filename         = "edgeapp/pkg/edgeapp.tar.gz"
    source_code_hash = data.fastly_package_hash.edgeapp.hash
  }

  backend {
    name              = "fastlyapi"
    address           = "api.fastly.com"
    override_host     = "api.fastly.com"
    ssl_cert_hostname = "api.fastly.com"
    ssl_sni_hostname  = "api.fastly.com"
    port              = 443
    use_ssl           = true
  }

  resource_link {
    name        = "secrets"
    resource_id = var.store_id
  }

  force_destroy = true
}