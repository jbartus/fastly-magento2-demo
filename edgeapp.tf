#######################################################################
## example javascript compute@edge application 
#######################################################################

# workaround for not having a fastly_secretstore resource yet
resource "terraform_data" "secret_store" {
  provisioner "local-exec" {
    when    = create
    command = "fastly secret-store create --name secrets --quiet"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "fastly secret-store delete --store-id=$(fastly secret-store list --json --quiet | jq '.[] | select(.name == \"secrets\") | .id' -r) --quiet"
  }
}

data "external" "secret_store" {
  program    = ["bash", "secret-store.sh"]
  depends_on = [terraform_data.secret_store]
}

resource "terraform_data" "secret_store_entry" {
  provisioner "local-exec" {
    command = "echo -n ${var.fastly_api_key} | fastly secret-store-entry create --store-id=${data.external.secret_store.result.id} --name=fastly-key --quiet --stdin"
  }
}

# do an initial build to save a manual step for fresh checkouts
resource "terraform_data" "build_app" {
  provisioner "local-exec" {
    command = "cd edgeapp && npm install && fastly compute build --quiet"
  }
}

# consistently sorts files before hashing to avoid extra deploys
data "fastly_package_hash" "edgeapp" {
  filename   = "edgeapp/pkg/edgeapp.tar.gz"
  depends_on = [terraform_data.build_app]
}

resource "fastly_service_compute" "demo" {
  name = "${var.site_name}-wasm"

  domain {
    name = "${var.site_name}.edgecompute.app"
  }

  package {
    filename         = "edgeapp/pkg/edgeapp.tar.gz"
    source_code_hash = data.fastly_package_hash.edgeapp.hash
  }

  # the app calls the fastly api for the list of pops
  backend {
    name              = "fastlyapi"
    address           = "api.fastly.com"
    override_host     = "api.fastly.com"
    ssl_cert_hostname = "api.fastly.com"
    ssl_sni_hostname  = "api.fastly.com"
    port              = 443
    use_ssl           = true
  }

  # link this app to the secret store containing the read-only fastly api key
  resource_link {
    name        = "secrets"
    resource_id = data.external.secret_store.result.id
  }

  force_destroy = true
}