#!/bin/bash
# System Monitoring Script
# Author: Defebs-vpn
# Date: 2025-02-16

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo "=============================="
echo "     SYSTEM MONITORING       "
echo "=============================="

# Check CPU usage
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
echo -e "${YELLOW}CPU Usage: $cpu_usage%${NC}"

# Check Memory usage
mem_usage=$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }')
echo -e "${YELLOW}Memory Usage: $mem_usage${NC}"

# Check Disk usage
disk_usage=$(df -h / | awk 'NR==2{print $5}')
echo -e "${YELLOW}Disk Usage: $disk_usage${NC}"

# Active connections
echo -e "\n${GREEN}Active Connections:${NC}"
netstat -tnp | grep ESTABLISHED | grep -E ':80|:443|:22' | wc -l

# Service Status
echo -e "\n${GREEN}Service Status:${NC}"
echo "SSH: $(systemctl is-active ssh)"
echo "X-Ray: $(systemctl is-active xray)"
echo "WebSocket: $(systemctl is-active ws-ssh)"

# List active users
echo -e "\n${GREEN}Active Users:${NC}"
who

# Bandwidth usage
echo -e "\n${GREEN}Bandwidth Usage:${NC}"
vnstat -h | tail -n 3