#!/bin/bash
# Firewall Configuration for NUBVPN
# Author: Defebs-vpn
# Date: 2025-02-16

# Load port configurations
source /etc/nubvpn/ports.conf

# Reset iptables
iptables -F
iptables -X

# Default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow SSH
iptables -A INPUT -p tcp --dport $SSH_PORT -j ACCEPT

# Allow HTTP/HTTPS
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Allow VPN Ports
iptables -A INPUT -p tcp --dport $SSH_WS_PORT -j ACCEPT
iptables -A INPUT -p tcp --dport $XRAY_PORT -j ACCEPT
iptables -A INPUT -p tcp --dport $XRAY_VMESS_PORT -j ACCEPT
iptables -A INPUT -p tcp --dport $XRAY_VLESS_PORT -j ACCEPT
iptables -A INPUT -p tcp --dport $XRAY_TROJAN_PORT -j ACCEPT

# Save rules
iptables-save > /etc/iptables/rules.v4