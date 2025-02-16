#!/bin/bash
# X-Ray Installation Script
# Author: Defebs-vpn
# Date: 2025-02-16

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}Installing X-Ray...${NC}"

# Download X-Ray
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# Create X-Ray config directory
mkdir -p /usr/local/etc/xray

# Configure X-Ray
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
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/vless"
        },
        "security": "tls",
        "tlsSettings": {
          "certificates": []
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
      },
      "streamSettings": {
        "network": "tcp",
        "security": "tls",
        "tlsSettings": {
          "certificates": []
        }
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

# Enable and start X-Ray
systemctl enable xray
systemctl restart xray

echo -e "${GREEN}X-Ray Installation Completed!${NC}"