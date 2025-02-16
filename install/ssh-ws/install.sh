#!/bin/bash
# SSH WebSocket Installation Script
# Author: Defebs-vpn
# Date: 2025-02-16

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}Installing SSH WebSocket...${NC}"

# Install required packages
apt-get install -y openssh-server python3 python3-pip nginx

# Install WebSocket proxy
pip3 install websockify

# Backup original SSH config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Configure SSH
cat > /etc/ssh/sshd_config <<EOF
Port 22
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
PermitRootLogin yes
MaxSessions 1000
PubkeyAuthentication yes
PasswordAuthentication yes
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
ClientAliveInterval 120
ClientAliveCountMax 2
UseDNS no
EOF

# Create WebSocket Service
cat > /etc/systemd/system/ws-ssh.service <<EOF
[Unit]
Description=SSH WebSocket Proxy
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/websockify --web /usr/share/nginx/html 80 localhost:22
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Enable and start services
systemctl restart ssh
systemctl enable ws-ssh
systemctl start ws-ssh

echo -e "${GREEN}SSH WebSocket Installation Completed!${NC}"