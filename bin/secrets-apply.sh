export TF_VAR_store_id="$(fastly secret-store create --name=secrets -j | jq '.id' -r)"
cat edgeapp/.secrets | fastly secret-store-entry create --store-id=${TF_VAR_store_id} --name=fastly-key --stdin