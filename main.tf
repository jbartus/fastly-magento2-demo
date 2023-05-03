module "fastly" {
  source    = "./modules/fastly"
  origin_ip = module.google.origin_ip
  site_name = var.site_name
}

module "sigsci" {
  source     = "./modules/sigsci"
  fastly_sid = module.fastly.fastly_sid
  site_name = var.site_name
}

module "google" {
  source = "./modules/google"
}