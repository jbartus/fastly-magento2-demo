output "fastly_sid" {
    description = "fastly service ID"
    value = fastly_service_vcl.demo_service.id
}