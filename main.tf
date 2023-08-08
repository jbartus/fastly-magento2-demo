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
    shield         = "pdx-or-us"
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

  logging_bigquery {
    name         = "bigquery"
    project_id   = google_service_account.bq_writer.project
    dataset      = google_bigquery_dataset.logs_ds.dataset_id
    table        = google_bigquery_table.logs_table.table_id
    account_name = google_service_account.bq_writer.account_id
    format       = file("log_format_string.json")
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