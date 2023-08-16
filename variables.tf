variable "site_name" {
  type = string
}

variable "magento_pub_key" {
  type = string
}

variable "magento_priv_key" {
  type = string
}

variable "fastly_api_key" {
  type = string
}

variable "ssh_pub_key" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

variable "ssh_priv_key" {
  type    = string
  default = "~/.ssh/id_rsa"
}

variable "rhack_digest" {
  type    = string
  default = "sha256:101de50054c70cb0ab093f3030f384ef489f14f856d91cd7fa9cd10d4e45bc28"
}

variable "sigsci_corp" {
  type = string
}

variable "sigsci_email" {
  type = string
}

variable "sigsci_token" {
  type = string
}

variable "google_project" {
  type = string
}

variable "google_region" {
  type    = string
  default = "us-east1"
}

variable "google_zone" {
  type    = string
  default = "us-east1-b"
}