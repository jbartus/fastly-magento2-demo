source .env

SERVICE_ID="$(fastly service describe --service-name=${TF_VAR_site_name}-wasm -j | jq '.ID' -r)"
STORE_ID="$(fastly secret-store create --name=secrets -j | jq '.id' -r)"
cat edgeapp/.secrets | fastly secret-store-entry create --store-id=${STORE_ID} --name=fastly-key --stdin
fastly resource-link create -r ${STORE_ID} -s ${SERVICE_ID} --version=active --autoclone
fastly service-version activate --service-id=${SERVICE_ID} --version=latest