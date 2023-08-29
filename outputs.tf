output "fastly_sid" {
  description = "fastly service ID"
  value       = fastly_service_vcl.demo_service.id
}

output "tab1" {
  value = "https://${var.site_name}.edgecompute.app"
}

output "tab2" {
  value = "https://${var.site_name}.freetls.fastly.net"
}

output "tab3" {
  value = "https://manage.fastly.com/observe/dashboard/system/overview/realtime/${fastly_service_vcl.demo_service.id}"
}

output "tab4" {
  value = "https://dashboard.signalsciences.net/corps/${var.sigsci_corp}/sites/${var.site_name}?dashboardId=000000000000000000000001&from=-1h"
}