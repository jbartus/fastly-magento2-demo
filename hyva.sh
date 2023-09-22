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

composer require yireo/magento2-theme-commands
bin/magento module:enable Yireo_ThemeCommands
bin/magento theme:change Hyva/default

bin/magento setup:static-content:deploy
bin/magento config:set customer/captcha/enable 0
bin/magento cache:clean
bin/magento cache:flush
