#!/bin/bash
# Log Clearing Script
# Author: Defebs-vpn
# Date: 2025-02-16 13:55:14

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

# Clear log files
echo > /var/log/nubvpn/access/xray-access.log
echo > /var/log/nubvpn/error/xray-error.log
echo > /var/log/nubvpn/access/nginx-access.log
echo > /var/log/nubvpn/error/nginx-error.log

# Remove old log archives
find /var/log/nubvpn/ -name "*.gz" -type f -delete

echo -e "${GREEN}Logs have been cleared successfully${NC}"