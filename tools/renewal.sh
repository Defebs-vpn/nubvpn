#!/bin/bash
# User Account Renewal Script
# Author: Defebs-vpn
# Date: 2025-02-16 13:55:14

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

clear
echo "=============================="
echo "    RENEW VPN USER ACCOUNT   "
echo "=============================="

# Get username
read -p "Username to renew: " username
read -p "Renew duration (days): " duration

if id "$username" >/dev/null 2>&1; then
    # Calculate new expiry date
    current_exp=$(grep "Expired:" /etc/nubvpn/users/$username/config.conf | cut -d: -f2- | xargs)
    new_exp=$(date -d "$current_exp + $duration days" +"%Y-%m-%d")
    
    # Update system expiry
    chage -E $(date -d "$new_exp" +"%Y-%m-%d") $username
    
    # Update config file
    sed -i "s/Expired: .*/Expired: $new_exp/g" /etc/nubvpn/users/$username/config.conf
    
    echo -e "${GREEN}Account $username has been renewed${NC}"
    echo -e "New expiration date: $new_exp"
else
    echo -e "${RED}User $username does not exist${NC}"
fi