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
    override_host  = "${var.site_name}.freetls.fastly.net"
    use_ssl        = "true"
    ssl_check_cert = "false"
    shield         = "pdx-or-us"
  }

  product_enablement {
    image_optimizer = true
  }

  force_destroy = true

  snippet {
    name    = "recv"
    type    = "recv"
    content = file("vcl/recv.vcl")
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