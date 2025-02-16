#!/bin/bash
# Backup Configuration Script
# Author: Defebs-vpn
# Date: 2025-02-16 13:55:14

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

# Backup directory
backup_dir="/root/backup"
mkdir -p $backup_dir

# Current date
date=$(date +%Y-%m-%d-%H%M%S)
backup_file="nubvpn-backup-$date.zip"

# Create temp directory
temp_dir="/tmp/backup-$date"
mkdir -p $temp_dir

# Backup configurations
cp -r /etc/nubvpn $temp_dir/
cp -r /usr/local/etc/xray $temp_dir/
cp /etc/nginx/conf.d/* $temp_dir/
cp /etc/ssh/sshd_config $temp_dir/

# Backup user data
cp -r /etc/nubvpn/users $temp_dir/

# Create backup archive
cd $temp_dir
zip -r $backup_dir/$backup_file *

# Clean up
rm -rf $temp_dir

echo -e "${GREEN}Backup completed: $backup_file${NC}"