#!/bin/bash
# Environment Setup for NUBVPN
# Author: Defebs-vpn
# Date: 2025-02-16

# VPN Configuration
export NUBVPN_HOME="/etc/nubvpn"
export NUBVPN_LOGS="/var/log/nubvpn"

# Default Ports
export SSH_PORT="22"
export SSH_WS_PORT="80"
export XRAY_PORT="443"

# System Settings
export TIMEZONE="Asia/Jakarta"

# Auto update settings
export AUTO_UPDATE="true"
export UPDATE_INTERVAL="7" # days

# Apply timezone
timedatectl set-timezone $TIMEZONE