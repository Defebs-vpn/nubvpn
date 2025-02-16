#!/bin/bash
# System Status Check Script
# Author: Defebs-vpn
# Date: 2025-02-16

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo "=============================="
echo "      SYSTEM STATUS          "
echo "=============================="

# Check all services
check_service() {
    if systemctl is-active --quiet $1; then
        echo -e "$1: ${GREEN}Running${NC}"
    else
        echo -e "$1: ${RED}Stopped${NC}"
    fi
}

echo "Service Status:"
check_service ssh
check_service xray
check_service ws-ssh
check_service nginx

# Check ports
echo -e "\nPort Status:"
source /etc/nubvpn/ports.conf

check_port() {
    if netstat -tuln | grep -q ":$1 "; then
        echo -e "Port $1: ${GREEN}Open${NC}"
    else
        echo -e "Port $1: ${RED}Closed${NC}"
    fi
}

check_port $SSH_PORT
check_port $SSH_WS_PORT
check_port $XRAY_PORT
check_port $XRAY_VMESS_PORT
check_port $XRAY_VLESS_PORT
check_port $XRAY_TROJAN_PORT

# Check system resources
echo -e "\nSystem Resources:"
echo "CPU Load: $(uptime | awk -F'load average:' '{ print $2 }')"
echo "Memory Usage: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
echo "Disk Usage: $(df -h / | awk 'NR==2 {print $5}')"

# Check expired users
echo -e "\nExpired Users:"
for user in $(ls /etc/nubvpn/users/); do
    exp=$(grep "Expired:" /etc/nubvpn/users/$user/config.conf | cut -d: -f2-)
    if [[ $(date -d "$exp" +%s) -lt $(date +%s) ]]; then
        echo -e "${RED}$user - Expired on $exp${NC}"
    fi
done