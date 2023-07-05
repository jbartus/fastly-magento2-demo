resource "fastly_service_vcl" "demo_service" {
  name = var.site_name

  domain {
    name = "${var.site_name}.global.ssl.fastly.net"
  }

  backend {
    address = var.origin_ip
    name    = "${var.site_name}-origin"
    port    = 80
    shield  = "ewr-nj-us"
  }

  snippet {
    name    = "init"
    type    = "init"
    content = file("${path.module}/vcl/init.vcl")
  }

  snippet {
    name    = "recv"
    type    = "recv"
    content = file("${path.module}/vcl/recv.vcl")
  }

  snippet {
    name    = "error"
    type    = "error"
    content = file("${path.module}/vcl/error.vcl")
  }

  snippet {
    name    = "deliver"
    type    = "deliver"
    content = file("${path.module}/vcl/deliver.vcl")
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