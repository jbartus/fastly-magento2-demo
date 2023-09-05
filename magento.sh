# mysql db and db user
sudo apt -y install mysql-server
sudo mysql <<SQL
CREATE DATABASE magento2;
CREATE USER 'magento2'@'localhost' IDENTIFIED BY 'magento-test-pass';
GRANT ALL PRIVILEGES ON magento2.* TO 'magento2'@'localhost';
FLUSH PRIVILEGES;
SET GLOBAL innodb_buffer_pool_size=4294967296;
SQL

# install elasticsearch
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elastic.gpg
echo "deb [signed-by=/usr/share/keyrings/elastic.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo apt update
sudo apt -y install elasticsearch
sudo service elasticsearch start

# configure webserver
sudo apt -y install php php-zip php-curl php-xml php-gd php-intl php-mysql php-soap php-mbstring php-bcmath curl unzip
sudo a2enmod rewrite
sudo a2enmod expires

# enable .htaccess
sudo tee -a /etc/apache2/sites-available/default-ssl.conf <<EOF > /dev/null
<Directory "/var/www/html">
        AllowOverride All
</Directory>
EOF

# move the docroot
sudo mkdir /var/www/html/magento2
sudo chown ubuntu:www-data /var/www/html/magento2
sudo chmod g+ws /var/www/html/magento2
sudo sed -i 's;DocumentRoot /var/www/html;DocumentRoot /var/www/html/magento2;' /etc/apache2/sites-available/default-ssl.conf
sudo service apache2 restart

# install composer
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

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
--admin-firstname=admin \
--admin-lastname=admin \
--admin-email=admin@admin.com \
--admin-user=admin \
--admin-password=fastly123 \
--base-url=https://${base_url}/ \
--backend-frontname="admin_fsly" \
--currency=USD \
--db-user=magento2 \
--db-password=magento-test-pass \
--language=en_US \
--timezone=America/New_York \
--use-rewrites=1

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
bin/magento fastly:conf:set --upload-vcl true

# set mode to prod
bin/magento config:set dev/js/minify_files 1
bin/magento config:set dev/css/minify_files 1
bin/magento config:set dev/template/minify_html 1
bin/magento deploy:mode:set production