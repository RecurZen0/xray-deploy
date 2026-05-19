#!/bin/bash
# 环境变量与路径
REPO_URL="https://raw.githubusercontent.com/你的用户名/xray-reality-project/main"
XRAY_CONF="/usr/local/etc/xray/config.json"

echo "========== [1/4] 环境增强与 BBR 优化 =========="
yum install -y curl wget unzip
curl -sL ${REPO_URL}/scripts/sys_optimize.sh | bash

echo "========== [2/4] 安装 Xray 核心 =========="
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

echo "========== [3/4] 生成 Reality 身份凭证 =========="
UUID=$(cat /proc/sys/kernel/random/uuid)
KEYS=$(/usr/local/bin/xray x25519)
PRIV_KEY=$(echo "$KEYS" | grep "Private key" | awk '{print $3}')
PUB_KEY=$(echo "$KEYS" | grep "Public key" | awk '{print $3}')
SHORT_ID=$(openssl rand -hex 4)

# 拉取模板并替换密钥
curl -sL ${REPO_URL}/config/xray_reality.json -o $XRAY_CONF
sed -i "s/YOUR_UUID_HERE/$UUID/g" $XRAY_CONF
sed -i "s|YOUR_PRIVATE_KEY_HERE|$PRIV_KEY|g" $XRAY_CONF
sed -i "s/YOUR_SHORT_ID_HERE/$SHORT_ID/g" $XRAY_CONF

echo "========== [4/4] 启动安全服务 =========="
systemctl enable xray
systemctl restart xray

# 打印客户端配置信息
SERVER_IP=$(curl -s ifconfig.me)
echo "--------------------------------------------------"
echo "部署完成！请手动保存以下客户端配置信息 (无域名模式):"
echo "地址 (Address): $SERVER_IP"
echo "端口 (Port): 443"
echo "用户 ID (UUID): $UUID"
echo "流控 (Flow): xtls-rprx-vision"
echo "传输协议 (Network): TCP"
echo "伪装域名 (SNI): www.microsoft.com"
echo "Public Key: $PUB_KEY"
echo "Short ID: $SHORT_ID"
echo "安全传输 (Security): reality"
echo "--------------------------------------------------"