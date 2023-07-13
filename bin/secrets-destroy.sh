source .env

LINK_ID=$(fastly resource-link list --service-name=${TF_VAR_site_name}-wasm --version active -j | jq '.[0].id' -r)
fastly resource-link delete --id=${LINK_ID} --version=latest --service-name=${TF_VAR_site_name}-wasm --autoclone
fastly service-version activate --service-name=${TF_VAR_site_name}-wasm --version=latest
STORE_ID=$(fastly secret-store list | grep secrets | awk '{print $2}')
fastly secret-store delete --store-id=${STORE_ID}