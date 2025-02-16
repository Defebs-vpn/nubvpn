#!/bin/bash
# Auto Update Script
# Author: Defebs-vpn
# Date: 2025-02-16 13:55:14

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

echo "Checking for updates..."

# Update system packages
apt-get update
apt-get upgrade -y

# Update X-Ray
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# Update NUBVPN scripts
wget -O /tmp/update.zip https://github.com/Defebs-vpn/nubvpn/archive/main.zip
unzip -o /tmp/update.zip -d /tmp/
cp -rf /tmp/nubvpn-main/* /etc/nubvpn/
rm -rf /tmp/update.zip /tmp/nubvpn-main

# Restart services
systemctl restart ssh
systemctl restart xray
systemctl restart nginx

echo -e "${GREEN}Update completed successfully${NC}"