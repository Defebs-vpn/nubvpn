#!/bin/bash
# User Management - Delete User Script
# Author: Defebs-vpn
# Date: 2025-02-16

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

clear
echo "=============================="
echo "      DELETE VPN USER        "
echo "=============================="

# Get username
read -p "Username to delete: " username

# Check if user exists
if id "$username" >/dev/null 2>&1; then
    # Delete system user
    userdel -f $username
    
    # Remove from X-Ray config
    uuid=$(grep "UUID:" /etc/nubvpn/users/$username/config.conf | cut -d: -f2 | tr -d ' ')
    jq --arg uuid "$uuid" \
       '.inbounds[0].settings.clients = [.inbounds[0].settings.clients[] | select(.id != $uuid)]' \
       /usr/local/etc/xray/config.json > /tmp/config.json && \
    mv /tmp/config.json /usr/local/etc/xray/config.json
    
    # Remove user config
    rm -rf /etc/nubvpn/users/$username
    
    # Restart services
    systemctl restart xray
    
    echo -e "${GREEN}User $username has been deleted successfully${NC}"
else
    echo -e "${RED}User $username does not exist${NC}"
fi