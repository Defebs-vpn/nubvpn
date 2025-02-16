#!/bin/bash
# Port Change Script
# Author: Defebs-vpn
# Date: 2025-02-16 13:55:14

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo "=============================="
echo "      CHANGE PORT MENU       "
echo "=============================="
echo "1. Change SSH Port"
echo "2. Change SSH WebSocket Port"
echo "3. Change X-Ray VLESS Port"
echo "4. Change X-Ray VMess Port"
echo "5. Change X-Ray Trojan Port"
echo "6. Back to Main Menu"
echo "=============================="

read -p "Select an option [1-6]: " option

change_port() {
    local service=$1
    local current_port=$2
    echo -e "Current $service port: $current_port"
    read -p "Enter new port: " new_port
    
    # Check if port is available
    if netstat -tuln | grep ":$new_port " >/dev/null; then
        echo -e "${RED}Port $new_port is already in use${NC}"
        return 1
    fi
    
    # Update port configuration
    sed -i "s/$service\_PORT=.*/$service\_PORT=$new_port/" /etc/nubvpn/ports.conf
    
    # Update firewall
    bash /etc/nubvpn/security/firewall.sh
    
    echo -e "${GREEN}Port has been changed successfully${NC}"
    return 0
}

source /etc/nubvpn/ports.conf

case $option in
    1) change_port "SSH" $SSH_PORT ;;
    2) change_port "SSH_WS" $SSH_WS_PORT ;;
    3) change_port "XRAY_VLESS" $XRAY_PORT ;;
    4) change_port "XRAY_VMESS" $XRAY_VMESS_PORT ;;
    5) change_port "XRAY_TROJAN" $XRAY_TROJAN_PORT ;;
    6) exit 0 ;;
    *) echo -e "${RED}Invalid option${NC}" ;;
esac