#!/bin/bash
set -xe

cd /var/www/html/magento2

# install the fastly module
composer config repositories.fastly-magento2 git "https://github.com/fastly/fastly-magento2.git"
composer require fastly/magento2
bin/magento module:enable Fastly_Cdn
bin/magento setup:upgrade
bin/magento setup:static-content:deploy -f
bin/magento cache:flush

# configure the fastly module
bin/magento fastly:conf:set --enable --service-id ${service_id} --token ${api_key}
bin/magento fastly:conf:set --cache
bin/magento fastly:conf:set --test-connection
bin/magento fastly:conf:set --upload-vcl true