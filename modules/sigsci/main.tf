resource "sigsci_site" "demo_site" {
  display_name = var.site_name
  short_name   = var.site_name
  agent_level  = "block"
}

resource "sigsci_edge_deployment" "ngwaf_edge_demo" {
  site_short_name = var.site_name
  depends_on      = [sigsci_site.demo_site]
}

resource "sigsci_edge_deployment_service" "ngwaf_edge_demo_link" {
  site_short_name  = var.site_name
  fastly_sid       = var.fastly_sid
  activate_version = true
  percent_enabled  = 100
  depends_on       = [sigsci_edge_deployment.ngwaf_edge_demo]
}