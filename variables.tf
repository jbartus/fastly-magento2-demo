variable "site_name" {
  type = string
}

variable "fastly_api_key" {
  type = string
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

variable "ssh_pub_key" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

variable "ssh_priv_key" {
  type    = string
  default = "~/.ssh/id_rsa"
}

variable "magento_pub_key" {
  type = string
}

variable "magento_priv_key" {
  type = string
}

variable "hyva" {
  type = bool
}

variable "hyva_ssh_priv_key" {
  type = string
}

variable "puppeteer" {
  type = bool
}

variable "randomhack" {
  type = bool
}