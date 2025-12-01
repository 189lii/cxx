#!/bin/bash

# Sing-box Shadowsocks 一键安装脚本 (Debian 12)
# 支持 TCP/UDP/QUIC，防 DNS 泄漏版本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 配置参数
SING_BOX_VERSION="1.10.7"
SS_PORT=20555
SS_PASSWORD=$(openssl rand -base64 16)
CIPHER="aes-128-gcm"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Sing-box Shadowsocks 服务器安装${NC}"
echo -e "${GREEN}  (防 DNS 泄漏增强版)${NC}"
echo -e "${GREEN}========================================${NC}"

# 检查 root 权限
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}错误: 请使用 root 权限运行此脚本${NC}"
   exit 1
fi

# 更新系统
echo -e "${YELLOW}[1/7] 更新系统软件包...${NC}"
apt update && apt upgrade -y
apt install -y curl wget tar gzip ufw

# 下载并安装 Sing-box
echo -e "${YELLOW}[2/7] 下载 Sing-box ${SING_BOX_VERSION}...${NC}"
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        DOWNLOAD_ARCH="amd64"
        ;;
    aarch64)
        DOWNLOAD_ARCH="arm64"
        ;;
    *)
        echo -e "${RED}不支持的架构: $ARCH${NC}"
        exit 1
        ;;
esac

DOWNLOAD_URL="https://github.com/SagerNet/sing-box/releases/download/v${SING_BOX_VERSION}/sing-box-${SING_BOX_VERSION}-linux-${DOWNLOAD_ARCH}.tar.gz"

cd /tmp
wget -O sing-box.tar.gz "$DOWNLOAD_URL"
tar -xzf sing-box.tar.gz
mv sing-box-${SING_BOX_VERSION}-linux-${DOWNLOAD_ARCH}/sing-box /usr/local/bin/
chmod +x /usr/local/bin/sing-box
rm -rf sing-box.tar.gz sing-box-${SING_BOX_VERSION}-linux-${DOWNLOAD_ARCH}

# 创建配置目录
echo -e "${YELLOW}[3/7] 创建配置文件...${NC}"
mkdir -p /etc/sing-box

# 生成 Sing-box 配置 (纯转发模式，不处理 DNS)
cat > /etc/sing-box/config.json <<EOF
{
  "log": {
    "level": "info",
    "timestamp": true
  },
  "inbounds": [
    {
      "type": "shadowsocks",
      "tag": "ss-in",
      "listen": "::",
      "listen_port": ${SS_PORT},
      "tcp_fast_open": true,
      "tcp_multi_path": false,
      "udp_fragment": true,
      "sniff": false,
      "method": "${CIPHER}",
      "password": "${SS_PASSWORD}"
    }
  ],
  "outbounds": [
    {
      "type": "direct",
      "tag": "direct"
    },
    {
      "type": "block",
      "tag": "block"
    }
  ],
  "route": {
    "rules": [
      {
        "ip_is_private": true,
        "outbound": "block"
      }
    ],
    "final": "direct",
    "auto_detect_interface": true
  }
}
EOF

# 创建 systemd 服务
echo -e "${YELLOW}[4/7] 创建 systemd 服务...${NC}"
cat > /etc/systemd/system/sing-box.service <<EOF
[Unit]
Description=sing-box service
Documentation=https://sing-box.sagernet.org
After=network.target nss-lookup.target
Wants=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/sing-box run -c /etc/sing-box/config.json
Restart=on-failure
RestartSec=10s
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF

# 配置防火墙
echo -e "${YELLOW}[5/7] 配置防火墙规则...${NC}"
ufw --force enable
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow ${SS_PORT}/tcp
ufw allow ${SS_PORT}/udp

# 启用 IP 转发和优化内核参数
echo -e "${YELLOW}[6/7] 优化系统参数...${NC}"
cat >> /etc/sysctl.conf <<EOF

# Sing-box 优化参数
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
net.ipv4.tcp_fastopen = 3
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_rmem = 8192 262144 536870912
net.ipv4.tcp_wmem = 4096 16384 536870912
net.core.rmem_max = 536870912
net.core.wmem_max = 536870912
net.ipv4.tcp_mtu_probing = 1
fs.file-max = 1048576
net.core.somaxconn = 1024
net.ipv4.tcp_max_syn_backlog = 2048
EOF

sysctl -p

# 启动服务
echo -e "${YELLOW}[7/7] 启动 Sing-box 服务...${NC}"
systemctl daemon-reload
systemctl enable sing-box
systemctl start sing-box

# 获取服务器 IP
SERVER_IP=$(curl -s -4 ifconfig.me || curl -s -4 icanhazip.com)

# 获取主机名
HOSTNAME=$(hostname)

# 显示配置信息
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  安装完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Clash 配置格式:${NC}"
echo ""
echo -e "${GREEN}proxies:${NC}"
echo -e "${GREEN}  # 节点: ${HOSTNAME} shadowsocks${NC}"
echo -e "${GREEN}  - name: \"SS-111\"${NC}"
echo -e "${GREEN}    type: ss${NC}"
echo -e "${GREEN}    server: ${SERVER_IP}${NC}"
echo -e "${GREEN}    port: ${SS_PORT}${NC}"
echo -e "${GREEN}    cipher: ${CIPHER}${NC}"
echo -e "${GREEN}    password: \"${SS_PASSWORD}\"${NC}"
echo -e "${GREEN}    udp: true${NC}"
echo ""
echo -e "${YELLOW}传统 URI 格式:${NC}"
echo -e "  ${GREEN}ss://${CIPHER}:${SS_PASSWORD}@${SERVER_IP}:${SS_PORT}${NC}"
echo ""
echo -e "${YELLOW}管理命令:${NC}"
echo -e "  查看状态: ${GREEN}systemctl status sing-box${NC}"
echo -e "  启动服务: ${GREEN}systemctl start sing-box${NC}"
echo -e "  停止服务: ${GREEN}systemctl stop sing-box${NC}"
echo -e "  重启服务: ${GREEN}systemctl restart sing-box${NC}"
echo -e "  查看日志: ${GREEN}journalctl -u sing-box -f${NC}"
echo ""
echo -e "${YELLOW}配置文件位置:${NC}"
echo -e "  ${GREEN}/etc/sing-box/config.json${NC}"
echo ""
echo -e "${GREEN}========================================${NC}"

# 保存配置到文件
cat > /root/ss-config.txt <<EOF
========================================
Clash 配置格式
========================================
proxies:
  # 节点: ${HOSTNAME} shadowsocks
  - name: "SS-111"
    type: ss
    server: ${SERVER_IP}
    port: ${SS_PORT}
    cipher: ${CIPHER}
    password: "${SS_PASSWORD}"
    udp: true

========================================
传统 URI 格式
========================================
ss://${CIPHER}:${SS_PASSWORD}@${SERVER_IP}:${SS_PORT}

========================================
配置文件
========================================
/etc/sing-box/config.json

========================================
DNS 隐私说明
========================================
- 服务器端不处理 DNS 解析
- 所有 DNS 查询由客户端通过加密隧道发送
- 建议客户端使用 DoH/DoT 加密 DNS
========================================
EOF

echo -e "${GREEN}配置信息已保存到: /root/ss-config.txt${NC}"