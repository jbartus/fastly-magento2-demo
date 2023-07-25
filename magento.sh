# install the magento code
composer -g config http-basic.repo.magento.com ${repo_user} ${repo_pass}
composer create-project --no-interaction --repository-url=https://repo.magento.com/ magento/project-community-edition="2.4.5" /var/www/html/magento2
cd /var/www/html/magento2
find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
chown -R :www-data .
chmod u+x bin/magento

# setup magento
bin/magento setup:install \
 --base-url=https://${base_url}/ \
--backend-frontname="admin_fsly" \
--db-host=localhost \
--db-name=magento \
--db-user=magento \
--db-password=magento-test-pass \
--admin-firstname=admin \
--admin-lastname=admin \
--admin-email=admin@admin.com \
--admin-user=admin \
--admin-password=fastly123 \
--language=en_US \
--currency=USD \
--timezone=America/Chicago \
--use-rewrites=1 \
--search-engine=elasticsearch7 \
--elasticsearch-host=localhost \
--elasticsearch-port=9200 \
--elasticsearch-index-prefix=magento2 \
--elasticsearch-timeout=15

# disable 2FA since this is just a temporary demo site
bin/magento module:disable Magento_TwoFactorAuth

# configure sampledata for a demo site
composer config http-basic.repo.magento.com ${repo_user} ${repo_pass}
bin/magento sampledata:deploy
find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
bin/magento setup:upgrade

# install the fastly module
composer config repositories.fastly-magento2 git "https://github.com/fastly/fastly-magento2.git"
composer require fastly/magento2
bin/magento module:enable Fastly_Cdn
bin/magento setup:upgrade
bin/magento setup:di:compile
bin/magento cache:flush

# configure the fastly module
bin/magento fastly:conf:set --enable --service-id ${service_id} --token ${api_key}
bin/magento fastly:conf:set --cache
bin/magento fastly:conf:set --test-connection
bin/magento fastly:conf:set --upload-vcl --activate