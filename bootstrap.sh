#!/bin/bash
# 环境变量与路径
REPO_URL="https://raw.githubusercontent.com/RecurZen0/xray-deploy/refs/heads/main"
XRAY_CONF="/usr/local/etc/xray/config.json"

echo "========== [1/4] BBR optimizing =========="
apt install -y curl wget unzip
curl -sL ${REPO_URL}/scripts/sys_optimize.sh | bash

echo "========== [2/4] Installing Xray Core =========="
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

echo "========== [3/4] Generating Keys =========="
UUID=$(cat /proc/sys/kernel/random/uuid)
KEYS=$(/usr/local/bin/xray x25519)
PRIV_KEY=$(echo "$KEYS" | grep "Privatekey" | awk '{print $2}')
PUB_KEY=$(echo "$KEYS" | grep "Password" | awk '{print $3}')
SHORT_ID=$(openssl rand -hex 4)

# 拉取模板并替换密钥
curl -sL ${REPO_URL}/config/xray_reality.json -o $XRAY_CONF
sed -i "s/YOUR_UUID_HERE/$UUID/g" $XRAY_CONF
sed -i "s|YOUR_PRIVATE_KEY_HERE|$PRIV_KEY|g" $XRAY_CONF
sed -i "s/YOUR_SHORT_ID_HERE/$SHORT_ID/g" $XRAY_CONF

echo "========== [4/4] Start Service =========="
systemctl enable xray
systemctl restart xray
systemctl status xray

# 打印客户端配置信息
SERVER_IP=$(curl -s ifconfig.me)
echo "--------------------------------------------------"
echo "Deployed successfully! Please copy the following information"
echo "Address: $SERVER_IP"
echo "Port: 443"
echo "UUID: $UUID"
echo "Flow: xtls-rprx-vision"
echo "Network: TCP"
echo "SNI: www.yahoo.com"
echo "Public Key: $PUB_KEY"
echo "Short ID: $SHORT_ID"
echo "Security: reality"
echo "--------------------------------------------------"
