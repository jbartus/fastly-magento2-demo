output "fastly_sid" {
  description = "fastly service ID"
  value       = fastly_service_vcl.demo_service.id
}

output "tab1" {
  value = "https://${var.site_name}.edgecompute.app"
}

output "tab2" {
  value = "https://${var.site_name}.global.ssl.fastly.net"
}

output "tab3" {
  value = "https://manage.fastly.com/observe/dashboard/system/overview/realtime/${fastly_service_vcl.demo_service.id}"
}