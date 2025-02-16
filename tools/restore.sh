#!/bin/bash
# Restore Configuration Script
# Author: Defebs-vpn
# Date: 2025-02-16 13:55:14

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

clear
echo "=============================="
echo "    RESTORE CONFIGURATION    "
echo "=============================="

# List available backups
echo "Available backups:"
ls -1 /root/backup/

# Get backup file
read -p "Enter backup file name: " backup_file

if [ -f "/root/backup/$backup_file" ]; then
    # Create temp directory
    temp_dir="/tmp/restore-$(date +%s)"
    mkdir -p $temp_dir
    
    # Extract backup
    unzip "/root/backup/$backup_file" -d $temp_dir/
    
    # Restore configurations
    cp -r $temp_dir/nubvpn/* /etc/nubvpn/
    cp -r $temp_dir/xray/* /usr/local/etc/xray/
    cp $temp_dir/conf.d/* /etc/nginx/conf.d/
    cp $temp_dir/sshd_config /etc/ssh/
    
    # Restart services
    systemctl restart ssh
    systemctl restart xray
    systemctl restart nginx
    
    # Clean up
    rm -rf $temp_dir
    
    echo -e "${GREEN}Restore completed successfully${NC}"
else
    echo -e "${RED}Backup file not found${NC}"
fi