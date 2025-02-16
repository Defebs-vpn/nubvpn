#!/bin/bash
# NUBVPN Auto Installer Script
# Author: Defebs-vpn
# Last Updated: 2025-02-16 14:00:38

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner
clear
echo -e "${CYAN}=====================================================================${NC}"
echo -e "${PURPLE}                     NUBVPN AUTO INSTALLER                           ${NC}"
echo -e "${PURPLE}                     Author: Defebs-vpn                             ${NC}"
echo -e "${PURPLE}                     Date: 2025-02-16 14:00:38                      ${NC}"
echo -e "${CYAN}=====================================================================${NC}"

# Check root access
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}"
   exit 1
fi

# Function to display progress
show_progress() {
    echo -e "${YELLOW}[*] $1...${NC}"
}

# Function to check command status
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[✓] $1 completed successfully${NC}"
    else
        echo -e "${RED}[✗] $1 failed${NC}"
        exit 1
    fi
}

# Initial system setup
show_progress "Updating system packages"
apt-get update
apt-get upgrade -y
check_status "System update"

# Install essential packages
show_progress "Installing essential packages"
apt-get install -y \
    wget \
    curl \
    git \
    zip \
    unzip \
    ufw \
    python3 \
    python3-pip \
    iptables \
    net-tools \
    ntpdate \
    jq \
    vnstat \
    tmux \
    fail2ban \
    squid
check_status "Essential packages installation"

# Synchronize time
show_progress "Synchronizing system time"
ntpdate pool.ntp.org
timedatectl set-timezone Asia/Jakarta
check_status "Time synchronization"

# Create directory structure
show_progress "Creating directory structure"
mkdir -p /etc/nubvpn/{ssh,websocket,xray,cert}
mkdir -p /var/log/nubvpn/{access,error}
mkdir -p /usr/local/share/nubvpn/
check_status "Directory creation"

# Install SSH
show_progress "Installing and configuring SSH"
apt-get install -y openssh-server
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
Banner /etc/nubvpn/banner
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
EOF
check_status "SSH configuration"

# Install Nginx
show_progress "Installing and configuring Nginx"
apt-get install -y nginx
systemctl enable nginx
check_status "Nginx installation"

# Install X-Ray
show_progress "Installing X-Ray"
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
check_status "X-Ray installation"

# Configure X-Ray
show_progress "Configuring X-Ray"
cat > /usr/local/etc/xray/config.json <<EOF
{
  "log": {
    "loglevel": "warning",
    "access": "/var/log/nubvpn/access/xray-access.log",
    "error": "/var/log/nubvpn/error/xray-error.log"
  },
  "inbounds": [
    {
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [],
        "decryption": "none",
        "fallbacks": [
          {
            "dest": 80
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/vless"
        }
      }
    },
    {
      "port": 8443,
      "protocol": "vmess",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/vmess"
        }
      }
    },
    {
      "port": 2087,
      "protocol": "trojan",
      "settings": {
        "clients": []
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom"
    }
  ]
}
EOF
check_status "X-Ray configuration"

# Install WebSocket
show_progress "Installing WebSocket"
pip3 install websockify
check_status "WebSocket installation"

# Configure WebSocket Service
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
check_status "WebSocket service configuration"

# Configure default ports
show_progress "Configuring default ports"
cat > /etc/nubvpn/ports.conf <<EOF
SSH_PORT=22
SSH_WS_PORT=80
SSH_WS_PORT_ALT=2082
XRAY_PORT=443
XRAY_VMESS_PORT=8443
XRAY_VLESS_PORT=2083
XRAY_TROJAN_PORT=2087
EOF
check_status "Port configuration"

# Configure UFW
show_progress "Configuring firewall"
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 2082/tcp
ufw allow 2083/tcp
ufw allow 2087/tcp
ufw allow 8443/tcp
echo "y" | ufw enable
check_status "Firewall configuration"

# Install SSL Certificate (self-signed for initial setup)
show_progress "Generating SSL certificate"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nubvpn/cert/privkey.pem \
    -out /etc/nubvpn/cert/fullchain.pem \
    -subj "/C=ID/ST=DKI Jakarta/L=Jakarta/O=NUBVPN/CN=nubvpn.com"
check_status "SSL certificate generation"

# Copy management scripts
show_progress "Installing management scripts"
cp -r tools/* /usr/local/bin/
chmod +x /usr/local/bin/*
check_status "Management scripts installation"

# Enable and start services
show_progress "Starting services"
systemctl daemon-reload
systemctl enable ssh
systemctl enable xray
systemctl enable ws-ssh
systemctl enable nginx

systemctl restart ssh
systemctl restart xray
systemctl restart ws-ssh
systemctl restart nginx
check_status "Service activation"

# Create banner
cat > /etc/nubvpn/banner <<EOF
==========================================================
                    WELCOME TO NUBVPN
==========================================================
          © 2025 Defebs-vpn. All rights reserved.
==========================================================
EOF

# Final setup
show_progress "Performing final setup"
cd /root
wget -O /usr/local/bin/menu "https://raw.githubusercontent.com/Defebs-vpn/nubvpn/main/tools/menu.sh"
chmod +x /usr/local/bin/menu
check_status "Menu installation"

# Installation complete
clear
echo -e "${CYAN}=====================================================================${NC}"
echo -e "${GREEN}                  NUBVPN Installation Completed!                      ${NC}"
echo -e "${CYAN}=====================================================================${NC}"
echo -e "${YELLOW}Installation Details:${NC}"
echo -e "${PURPLE}• SSH Port: 22${NC}"
echo -e "${PURPLE}• SSH WebSocket Port: 80${NC}"
echo -e "${PURPLE}• VLESS Port: 443${NC}"
echo -e "${PURPLE}• VMess Port: 8443${NC}"
echo -e "${PURPLE}• Trojan Port: 2087${NC}"
echo -e "${CYAN}=====================================================================${NC}"
echo -e "${GREEN}Type 'menu' to access NUBVPN management console${NC}"
echo -e "${CYAN}=====================================================================${NC}"

# Save installation log
echo "NUBVPN installed on $(date)" > /etc/nubvpn/install.log
echo "Installer version: 1.0" >> /etc/nubvpn/install.log
echo "Installed by: Defebs-vpn" >> /etc/nubvpn/install.log

# Cleanup
apt-get clean
history -c