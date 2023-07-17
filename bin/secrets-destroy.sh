STORE_ID=$(fastly secret-store list | grep secrets | awk '{print $2}')
fastly secret-store delete --store-id=${STORE_ID}