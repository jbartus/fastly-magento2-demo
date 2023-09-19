#!/bin/bash
set -xeo pipefail

# install dependencies
sudo apt update
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y \
  libnss3 libx11-xcb1 libxcb-dri3-0 libdrm2 libpangocairo-1.0-0 libgtk-3-0 libatk1.0-0 libatk-bridge2.0-0 libcups2 \
  libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 libgbm1 libpango-1.0-0 libcairo2 libasound2

# install node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install node

# install puppeteer
npm install puppeteer

# set the target url
export SITE_URL=https://${url}

# run three virtual users on a loop
nohup bash -c 'while true; do node homepage.js && sleep `shuf -i 2-10 -n1`; done &'
sleep 10 && nohup bash -c 'while true; do node promobutton.js && sleep `shuf -i 2-10 -n1`; done &'
sleep 20 && nohup bash -c 'while true; do node shopper.js && sleep `shuf -i 2-10 -n1`; done &'
