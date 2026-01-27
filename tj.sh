#!/bin/bash

# 1. 环境清理与安装
apt update && apt install -y curl openssl
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# 2. 准备证书 (CN 严格匹配你的 SNI)
mkdir -p /etc/xray/cert
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/xray/cert/server.key -out /etc/xray/cert/server.crt \
-subj "/CN=tsinghua.edu.cn"
chmod 644 /etc/xray/cert/server.crt
chmod 644 /etc/xray/cert/server.key

# 3. 写入配置 (修复了上一版可能的路径和语法问题)
# 密码我设为: MyTrojanPass123 (你可以自行修改)
cat <<EOF > /usr/local/etc/xray/config.json
{
    "log": {
        "loglevel": "info"
    },
    "inbounds": [
        {
            "port": 20092,
            "protocol": "trojan",
            "settings": {
                "clients": [
                    {
                        "password": "MyTrojanPass123"
                    }
                ]
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
    "outbounds": [
        {
            "protocol": "freedom"
        }
    ]
}
EOF

# 4. 强制开放 Debian 系统防火墙 (nftables)
if command -v nft > /dev/null; then
    nft add rule inet filter input tcp dport 20092 accept
fi

# 5. 重启并验证
systemctl restart xray
sleep 1
systemctl status xray --no-pager