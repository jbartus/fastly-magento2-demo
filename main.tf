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