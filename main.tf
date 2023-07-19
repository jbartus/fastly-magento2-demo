#######################################################################
## a linux VM on GCP to serve as the origin webserver
#######################################################################

resource "google_compute_instance" "demo_origin_instance" {
  name         = "${var.site_name}-origin"
  machine_type = "n2-standard-2"
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
  metadata_startup_script = templatefile("vm-init.sh.tftpl", { magento_repo_user = var.magento_pub_key, magento_repo_pass = var.magento_priv_key })
  metadata = {
    ssh-keys = "root:${file("~/.ssh/id_rsa.pub")}"
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

  dictionary {
    name = "Edge_Security"
  }

  dynamicsnippet {
    name = "ngwaf_config_init"
    type = "init"
  }

  dynamicsnippet {
    name = "ngwaf_config_pass"
    type = "pass"
  }

  dynamicsnippet {
    name = "ngwaf_config_miss"
    type = "miss"
  }

  dynamicsnippet {
    name = "ngwaf_config_deliver"
    type = "deliver"
  }

  product_enablement {
    image_optimizer = true
  }

  force_destroy = true
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

resource "terraform_data" "magento_plugin_conf" {
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
      "cd /var/www/magento",
      "bin/magento fastly:conf:set --enable --service-id ${fastly_service_vcl.demo_service.id} --token FIXME --test-connection --cache", # --upload-vcl --activate
    ]
  }
  # wait for the waf to be done so the magento plugin's vcl activation doesn't step on it
  depends_on = [ sigsci_edge_deployment_service.ngwaf_edge_demo_link ]
}

#######################################################################
## example javascript compute@edge application 
#######################################################################

data "fastly_package_hash" "edgeapp" {
  filename = "edgeapp/pkg/edgeapp.tar.gz"
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