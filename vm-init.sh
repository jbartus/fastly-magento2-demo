# elasticsearch repo
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elastic.gpg
echo "deb [signed-by=/usr/share/keyrings/elastic.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list

# apt packages
apt update
apt -y install curl mysql-server elasticsearch php php-zip php-curl php-xml php-gd php-intl php-mysql php-soap php-mbstring php-bcmath unzip

# elasticsearch
systemctl start elasticsearch

# mysql db and db user
mysql <<SQL
CREATE DATABASE magento;
CREATE USER 'magento'@'localhost' IDENTIFIED BY 'magento-test-pass';
GRANT ALL PRIVILEGES ON magento.* TO 'magento'@'localhost';
FLUSH PRIVILEGES;
SQL

# enable mod_rewrite
a2enmod rewrite

# move the default virtualhost documentroot to the magento install
mkdir /var/www/html/magento2
sed -i 's/html/html\/magento2/' /etc/apache2/sites-enabled/000-default.conf

# enable .htaccess (note one big multiline command)
cat <<EOF >> /etc/apache2/sites-enabled/000-default.conf
<Directory "/var/www/html">
        AllowOverride All
</Directory>
EOF

# fix the https redirect loop
echo 'SetEnvIf HTTPS "on" HTTPS="on"' >> /etc/apache2/sites-enabled/000-default.conf

# restart apache
systemctl restart apache2

# install composer
export COMPOSER_HOME=/root/.config/composer
mkdir -p $${COMPOSER_HOME}
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

adduser magento_user --disabled-password --gecos ""
usermod -a -G www-data magento_user
chown magento_user:www-data /var/www/html/magento2
chmod g+ws /var/www/html/magento2