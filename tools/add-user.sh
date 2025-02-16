#!/bin/bash
# User Management - Add User Script
# Author: Defebs-vpn
# Date: 2025-02-16

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

clear
echo "=============================="
echo "       ADD NEW VPN USER      "
echo "=============================="

# Get user input
read -p "Username: " username
read -p "Password: " password
read -p "Expired (days): " expired

# Add system user
useradd -M -s /bin/false -e $(date -d "+$expired days" +"%Y-%m-%d") $username
echo "$username:$password" | chpasswd

# Generate UUID for X-Ray
uuid=$(xray uuid)

# Add to X-Ray config
jq --arg user "$username" \
   --arg uuid "$uuid" \
   '.inbounds[0].settings.clients += [{"id": $uuid, "email": $user}]' \
   /usr/local/etc/xray/config.json > /tmp/config.json && \
mv /tmp/config.json /usr/local/etc/xray/config.json

# Restart services
systemctl restart xray

# Create user config file
mkdir -p /etc/nubvpn/users/$username
cat > /etc/nubvpn/users/$username/config.conf <<EOF
Username: $username
Password: $password
Expired: $(date -d "+$expired days" +"%Y-%m-%d")
UUID: $uuid
Created: $(date +"%Y-%m-%d %H:%M:%S")
EOF

echo -e "${GREEN}User $username has been created successfully${NC}"
echo -e "Expired: $(date -d "+$expired days" +"%Y-%m-%d")"
echo -e "UUID: $uuid"