#!/bin/bash
# User Connection Limit Script
# Author: Defebs-vpn
# Date: 2025-02-16 13:55:14

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

clear
echo "=============================="
echo "    USER CONNECTION LIMIT    "
echo "=============================="

read -p "Username: " username
read -p "Max Connections: " max_conn

if id "$username" >/dev/null 2>&1; then
    # Update user config
    sed -i "/^${username}:/d" /etc/security/limits.conf
    echo "${username} hard maxlogins ${max_conn}" >> /etc/security/limits.conf
    
    # Kill excess connections
    current_conn=$(who | grep $username | wc -l)
    if [ $current_conn -gt $max_conn ]; then
        pkill -u $username
    fi
    
    echo -e "${GREEN}Connection limit set for $username: $max_conn${NC}"
else
    echo -e "${RED}User $username does not exist${NC}"
fi