#!/bin/bash
set -xeo pipefail

# install packages
sudo DEBIAN_FRONTEND=noninteractive apt -y install curl unzip mysql-server php libapache2-mod-php php-curl php-gd php-intl php-bcmath php-mbstring php-mysql php-soap php-xml php-zip

# setup db user and perms
sudo mysql <<SQL
CREATE USER 'wordpress'@'%' IDENTIFIED WITH mysql_native_password BY 'password';
GRANT ALL ON wordpress.* TO 'wordpress'@'%';
FLUSH PRIVILEGES;
SET GLOBAL innodb_buffer_pool_size=4294967296;
SQL

# configure webserver
sudo a2enmod rewrite

sudo tee -a /etc/apache2/sites-available/default-ssl.conf <<EOF > /dev/null
<Directory "/var/www/html">
        AllowOverride All
</Directory>
EOF

sudo service apache2 restart

# install wordpress command line utility
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

# take over docroot
sudo chown ubuntu:ubuntu /var/www/html
cd /var/www/html
sudo rm index.html

# install wordpress
wp core download
wp config create --dbname=wordpress --dbuser=wordpress --dbpass=password
wp db create
wp core install --url=${url} --title="demo blog" --admin_user=admin --admin_password=demo123 --admin_email=info@wp-cli.org

# configure pretty-permalinks
tee -a ~/.wp-cli/config.yml <<EOF > /dev/null
apache_modules:
  - mod_rewrite
EOF

wp rewrite structure '/%postname%/' --hard

# support uploads
sudo chown -R ubuntu:www-data /var/www/html/wp-content/uploads