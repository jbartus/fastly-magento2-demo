resource "fastly_service_vcl" "demo_service" {
  name = var.site_name

  domain {
    name    = "${var.site_name}.global.ssl.fastly.net"
  }

  backend {
    address = var.origin_ip
    name    = "localhost"
    port    = 80
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

#  lifecycle {
#    ignore_changes = [product_enablement]
#  }

  force_destroy = true
}