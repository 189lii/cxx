#!/bin/bash

# ================= 配置区 =================
# 填写你的 Telegram Bot Token 和 Chat ID
TG_TOKEN="7756669471:AAFstxnzCweHItNptwOf7UU-p6xj3pwnAI8"
TG_CHAT_ID="1792396794"
# 自定义密码，留空则随机生成
CUSTOM_PASS="MyTrojanPass123"
PORT=20092
SNI="yale.edu"
# ==========================================

# 1. 环境清理与安装
apt update && apt install -y curl openssl jq
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# 2. 准备证书
mkdir -p /etc/xray/cert
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/xray/cert/server.key -out /etc/xray/cert/server.crt \
-subj "/CN=$SNI"
chmod 644 /etc/xray/cert/server.*

# 3. 写入配置
PASS=${CUSTOM_PASS:-$(openssl rand -base64 12)}
cat <<EOF > /usr/local/etc/xray/config.json
{
    "log": { "loglevel": "info" },
    "inbounds": [
        {
            "port": $PORT,
            "protocol": "trojan",
            "settings": {
                "clients": [ { "password": "$PASS" } ]
            },
            "streamSettings": {
                "network": "tcp",
                "security": "tls",
                "tlsSettings": {
                    "certificates": [
                        {
                            "certificateFile": "/etc/xray/cert/server.crt",
                            "keyFile": "/etc/xray/cert/server.key"
                        }
                    ]
                }
            }
        }
    ],
    "outbounds": [ { "protocol": "freedom" } ]
}
EOF

# 4. 防火墙开放 (兼容 ufw/iptables/nft)
if command -v ufw > /dev/null; then ufw allow $PORT/tcp; fi
if command -v nft > /dev/null; then nft add rule inet filter input tcp dport $PORT accept; fi
iptables -I INPUT -p tcp --dport $PORT -j ACCEPT

# 5. 重启并验证
systemctl restart xray
sleep 1

# 6. 生成链接并推送
IP=$(curl -s https://api64.ipify.org)
# 针对 Trojan 协议的链接格式：trojan://password@ip:port?sni=xxx#备注
SHARE_LINK="trojan://$PASS@$IP:$PORT?sni=$SNI&allowInsecure=1#Xray_Trojan_$IP"

# 打印到屏幕
echo -e "\n--- 部署完毕 ---"
echo "节点链接: $SHARE_LINK"

# 推送到 Telegram
if [ "$TG_TOKEN" != "你的_BOT_TOKEN" ]; then
    MSG="✅ *Xray Trojan 部署成功* %0A%0A*IP:* \`$IP\` %0A*Port:* \`$PORT\` %0A*Pass:* \`$PASS\` %0A%0A*链接:* %0A\`$SHARE_LINK\`"
    curl -s -X POST "https://api.telegram.org/bot$TG_TOKEN/sendMessage" \
        -d "chat_id=$TG_CHAT_ID" \
        -d "text=$MSG" \
        -d "parse_mode=Markdown" > /dev/null
    echo "已推送到 Telegram 机器人"
else
    echo "未配置 Telegram Token，跳过推送。"
fi
