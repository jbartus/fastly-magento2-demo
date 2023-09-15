#!/bin/bash
set -xeo pipefail

cd /var/www/html

wp plugin install fastly
wp plugin activate fastly

# wp fastly configset general fastly_api_key ${api_key}
wp option patch insert fastly-settings-general fastly_api_key ${api_key}

# wp fastly configset general fastly_service_id ${service_id}
wp option patch insert fastly-settings-general fastly_service_id ${service_id}

# wp fastly configset general fastly_api_hostname 'https://api.fastly.com/'
wp option patch insert fastly-settings-general fastly_api_hostname 'https://api.fastly.com/'


curl -X POST https://${url}/wp-login.php -d 'log=admin&pwd=demo123' -c cookie-jar
curl https://${url}/wp-admin/admin-ajax.php --get -d 'action=fastly_vcl_update_ok&activate=1' --cookie cookie-jar
rm cookie-jar
