source .env

for i in `seq 1 50`
do 
    curl https://${TF_VAR_site_name}.global.ssl.fastly.net/pass -G --data-urlencode "q=<script>"
done