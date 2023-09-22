#!/bin/bash
set -xeo pipefail

cd /var/www/html/magento2

composer config repositories.hyva-themes/magento2-theme-module git git@gitlab.hyva.io:hyva-themes/magento2-theme-module.git
composer config repositories.hyva-themes/magento2-reset-theme git git@gitlab.hyva.io:hyva-themes/magento2-reset-theme.git
composer config repositories.hyva-themes/magento2-email-module git git@gitlab.hyva.io:hyva-themes/magento2-email-module.git
composer config repositories.hyva-themes/magento2-default-theme git git@gitlab.hyva.io:hyva-themes/magento2-default-theme.git

ssh-keyscan gitlab.hyva.io >> ~/.ssh/known_hosts

composer require hyva-themes/magento2-default-theme --prefer-source

bin/magento setup:upgrade

# Navigate to the Content > Design > Configuration admin section and activate the hyva/default theme.

bin/magento setup:static-content:deploy
