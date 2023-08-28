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
CREATE DATABASE magento2;
CREATE USER 'magento2'@'localhost' IDENTIFIED BY 'magento-test-pass';
GRANT ALL PRIVILEGES ON magento2.* TO 'magento2'@'localhost';
FLUSH PRIVILEGES;
SET GLOBAL innodb_buffer_pool_size=4294967296;
SQL

# configure apache
a2enmod rewrite
a2enmod ssl
a2enmod expires
a2ensite default-ssl
a2dissite 000-default

# move the default virtualhost documentroot to the magento install
mkdir /var/www/html/magento2
sed -i 's;DocumentRoot /var/www/html;DocumentRoot /var/www/html/magento2;' /etc/apache2/sites-available/default-ssl.conf

# enable .htaccess
cat <<EOF >> /etc/apache2/sites-available/default-ssl.conf
<Directory "/var/www/html">
        AllowOverride All
</Directory>
EOF

# restart apache
service apache2 restart

# install composer
export COMPOSER_HOME=/root/.config/composer
mkdir -p $${COMPOSER_HOME}
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

adduser magento_user --disabled-password --gecos ""
usermod -a -G www-data magento_user
chown magento_user:www-data /var/www/html/magento2
chmod g+ws /var/www/html/magento2