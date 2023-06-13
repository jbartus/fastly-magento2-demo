source .env

curl https://${TF_VAR_site_name}.global.ssl.fastly.net/dog.jpg -svo /dev/null 2>&1 | grep -i content-length

curl https://${TF_VAR_site_name}.global.ssl.fastly.net/dog.jpg -G --data-urlencode 'io=1' --data-urlencode 'auto=avif' -H 'accept: image/avif' -svo /dev/null 2>&1 | grep -i content-length