source .env

echo "GET https://${TF_VAR_site_name}.global.ssl.fastly.net" | vegeta attack -rate 9 -duration 3m | vegeta report --every 1s