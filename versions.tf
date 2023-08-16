terraform {
  required_providers {
    fastly = {
      source = "fastly/fastly"
    }
    sigsci = {
      source = "signalsciences/sigsci"
    }
  }
}

provider "fastly" {
  api_key = var.fastly_api_key
}

provider "sigsci" {
  corp           = var.sigsci_corp
  email          = var.sigsci_email
  auth_token     = var.sigsci_token
  fastly_api_key = var.fastly_api_key
}

provider "google" {
  project = var.google_project
  region  = var.google_region
  zone    = var.google_zone
}