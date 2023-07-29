#######################################################################
## a linux VM on GCP to serve as the origin webserver
#######################################################################

resource "google_compute_instance" "demo_origin_instance" {
  name         = "${var.site_name}-origin"
  machine_type = "c3-standard-4"
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
  tags                    = ["https-server"]
  # do all the server setup steps done by root
  metadata_startup_script = file("vm-init.sh")
  # pre-place the magento script now as the 'file' provisioner
  # doesnt work in terraform_data resources (used later)
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
    address        = google_compute_instance.demo_origin_instance.network_interface.0.access_config.0.nat_ip
    name           = "${var.site_name}-origin"
    port           = 443
    use_ssl        = "true"
    ssl_check_cert = "false"
    shield         = "ewr-nj-us"
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

  # ignore resources the ngwaf or magento plugin change
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

# deploy a managed ngwaf@edge agent on the fastly side
resource "sigsci_edge_deployment" "ngwaf_edge_demo" {
  site_short_name = sigsci_site.demo_site.short_name
}

# link the varnish service to the ngwaf@edge agent backend
resource "sigsci_edge_deployment_service" "ngwaf_edge_demo_link" {
  site_short_name  = sigsci_edge_deployment.ngwaf_edge_demo.site_short_name
  fastly_sid       = fastly_service_vcl.demo_service.id
  activate_version = true
  percent_enabled  = 100
}

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

#######################################################################
## example javascript compute@edge application 
#######################################################################

# workaround for not having a fastly_secretstore resource yet
resource "terraform_data" "secret_store" {
  provisioner "local-exec" {
    when    = create
    command = "fastly secret-store create --name secrets --quiet"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "fastly secret-store delete --store-id=$(fastly secret-store list --json --quiet | jq '.data[] | select(.name == \"secrets\") | .id' -r) --quiet"
  }
}

data "external" "secret_store" {
  program    = ["bash", "secret-store.sh"]
  depends_on = [terraform_data.secret_store]
}

resource "terraform_data" "secret_store_entry" {
  provisioner "local-exec" {
    command = "fastly secret-store-entry create --store-id=${data.external.secret_store.result.id} --name=fastly-key --file=edgeapp/.secrets --quiet"
  }
}

# do an initial build to save a manual step for fresh checkouts
resource "terraform_data" "build_app" {
  provisioner "local-exec" {
    command = "cd edgeapp && npm install && fastly compute build --quiet"
  }
}

# consistently sorts files before hashing to avoid extra deploys
data "fastly_package_hash" "edgeapp" {
  filename   = "edgeapp/pkg/edgeapp.tar.gz"
  depends_on = [terraform_data.build_app]
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

  # the app calls the fastly api for the list of pops
  backend {
    name              = "fastlyapi"
    address           = "api.fastly.com"
    override_host     = "api.fastly.com"
    ssl_cert_hostname = "api.fastly.com"
    ssl_sni_hostname  = "api.fastly.com"
    port              = 443
    use_ssl           = true
  }

  # link this app to the secret store containing the read-only fastly api key
  resource_link {
    name        = "secrets"
    resource_id = data.external.secret_store.result.id
  }

  force_destroy = true
}