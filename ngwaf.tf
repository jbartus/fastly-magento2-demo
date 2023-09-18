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

# create a list
resource "sigsci_corp_list" "sanctioned-countries" {
  name        = "Sanctioned Countries"
  type        = "country"
  description = "List of Sanctioned Countries"
  entries = [
    "RU",
    "CU",
    "KP",
    "IR"
  ]
}

# block traffic using the list
resource "sigsci_corp_rule" "sanctions" {
  depends_on     = [sigsci_corp_list.sanctioned-countries]
  reason         = "sanctions"
  enabled        = true
  corp_scope     = "global"
  type           = "request"
  expiration     = ""
  requestlogging = "sampled"
  group_operator = "any"
  conditions {
    type     = "single"
    field    = "country"
    operator = "inList"
    value    = "corp.sanctioned-countries"
  }
  actions {
    type = "block"
  }
}