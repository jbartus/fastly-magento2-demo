#!/bin/bash

set -xeo pipefail

sudo DEBIAN_FRONTEND=noninteractive apt -y install libapache2-mod-security2 modsecurity-crs
sudo a2enmod security2
sudo mv /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf
sudo service apache2 restart