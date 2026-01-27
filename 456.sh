#!/bin/bash

# ================= 配置区 =================
TG_TOKEN="7756669471:AAFstxnzCweHItNptwOf7UU-p6xj3pwnAI8"
TG_CHAT_ID="1792396794"
CUSTOM_PASS="MyTrojanPass123"
PORT=20092

# 美国及全球知名域名池 (由你提供并整理)
DOMAIN_LIST=(
    "oracle.com" "panasonic.com" "libertymutualinsurancegroup.com" "freddiemac.com" "lufthansa.com"
    "waseda.jp" "pepsi.com" "cigna.com" "box.com" "netapp.com" "jnj.com" "abdn.ac.uk"
    "marathonpetroleum.com" "logitech.com" "cenovus.com" "lightspeedhq.com" "nike.com" "hp.com"
    "morganstanley.com" "saint-gobain.com" "dowchemical.com" "medtronic.com" "nbc.ca"
    "zimmerbiomet.com" "sutd.edu.sg" "metlife.com" "charite.de" "fanniemae.com" "opentext.com"
    "worldfuelservices.com" "bmo.com" "magna.com" "thermofisher.com" "ibm.com" "prudentialfinancial.com"
    "scotiabank.com" "canon.jp" "3m.com" "fresenius.com" "homedepot.com" "exelon.com"
    "energytransferequity.com" "hitachi.co.jp" "hokudai.ac.jp" "cognizant.com" "northwesternmutual.com"
    "arcelormittal.com" "wholefoodsmarket.com" "conocophillips.com" "salesforce.com" "porsche.com"
    "expressscriptsholding.com" "soumu.go.jp" "ekapija.com" "bestbuy.com" "bmw.com" "infosys.com"
    "deere.com" "deltaairlines.com" "cis Cisco.com" "okta.com" "ing.com" "terumo.com" "orange.com"
    "saputo.com" "aldi.us" "brookes.ac.uk" "newyorklifeinsurance.com" "slack.com" "intel.com"
    "washingtonpost.com" "nis.rs" "parkland.ca" "raymondjames.com" "mext.go.jp" "discord.com"
    "fortisinc.com" "humana.com" "ingrammicro.com" "silvercorpmetals.com" "couche-tard.com"
    "amazonaws.com" "siemens-healthineers.com" "honeywellgroup.com" "garmin.com" "riken.jp"
    "kroger.com" "fujifilm.com" "atlassian.com" "alphabet.com" "caasco.com" "nutrien.com"
    "timewarner.com" "bytedance.com" "adobe.com" "nafa.edu.sg" "berkshirehathaway.com"
    "ivanhoemines.com" "phillips66.com" "foxconn.com" "sysco.com" "nestle.de" "thyssenkrupp.com"
    "disney.com" "anthem.com" "skku.edu" "albertsons.com" "kcl.ac.uk" "novonordisk.com"
    "generalmotors.com" "emersongroup.com" "bankofamerica.com" "amd.com" "publixsupermarkets.com"
    "mercedes-benz.com" "toromont.com" "bungegroup.com" "comdirectbank.de" "telus.com" "asml.com"
    "bosch.com" "honeywellinternational.com" "visa.com" "comcast.com" "teck.com" "chs.com"
    "gianteagle.com" "baidu.com" "abbott.com" "dropbox.com" "paypal.com" "juniper.net"
    "imperialoil.ca" "unitedtechnologies.com" "microsoft.com" "tesla.com" "nokia.com"
    "stellajones.com" "digitalocean.com" "johnsoncontrols.com" "fortinet.com" "cmegroup.com"
    "unitedcontinentalholdings.com" "citrix.com" "generalelectric.com" "allegisgroup.com"
    "raytheongroup.com" "linde.com" "aetna.com" "goldmansachs.com" "albertaenergy.com"
    "uni-freiburg.de" "gitlab.com" "accenture.com" "jpmorganchase.com" "thewaltdisneycompany.com"
    "nationwide.com" "mofa.go.jp" "sony.co.jp" "roche.com" "gehealthcare.com" "valeroenergy.com"
    "statefarminsurance.com" "thewinegroup.com" "unilever.com" "adidas-group.com" "bostonscientific.com"
    "epicgames.com" "axa.com" "tcenergy.com" "nafa.edu" "dell.com" "safeway.com" "pembina.com"
    "tjx.com" "suncor.com" "bombardier.com" "intlfcstone.com" "foodlion.com" "verizon.com" "bd.com"
    "astrazeneca.com" "acsgroup.com" "allianz.com" "ford.com" "csisoftware.com" "mastercard.com"
    "massachusettsmutuallifeinsurance.com" "cancom.de" "sanofi.com" "avaya.com" "merckgroup.com"
    "stopandshop.com" "equinix.com" "gsk.com" "hy-vee.com" "rbc.com" "autodesk.com" "eldoradogold.com"
    "americanairlinesgroup.com" "lvmh.com" "daimler.com" "firstmajestic.com" "zf.com"
    "mondelezinternational.com" "generaldynamics.com" "bbraun.com" "capitalgroup.com" "loreal.com"
    "tiaa.com" "caterpillar.com" "mckesson.com" "heb.com" "nus.edu.sg" "chevron.com" "cibc.com"
    "att.com" "wellsfargo.com" "globant.com" "shoprite.com" "lmu.de" "mcdonalds.com" "publix.com"
    "thomsonreuters.com" "cgi.com" "cau.ac.kr" "linamar.com" "atsautomation.com" "first-quantum.com"
    "canadianimperialbank.com" "canon-medical.com" "pfizer.com" "encana.com" "cisco.com" "apple.com"
    "aircanada.com" "fedex.com" "coca-cola.com" "deutschetelekom.com" "aig.com" "greatwestlifeco.com"
    "wheatonpm.com" "gileadsciences.com" "intuit.com" "lowes.com" "b2gold.com" "citigroup.com"
    "smith-nephew.com" "sap.com" "st.com" "boeing.com" "ritchiebros.com" "ups.com" "danaher.com"
    "alcon.com" "olympus-global.com" "americanexpress.com" "barrick.com" "brookfield.com"
    "archerdanielsmidland.com" "dupont.com" "swansea.ac.uk" "volkswagen.de" "palantir.com"
    "godex.rs" "resmed.com" "tohoku.ac.jp" "starbucks.com" "phillips.com" "broadcom.com"
    "lenovo.com" "hearst.com" "f5.com" "hsbc.com" "heise.de" "amerisourcebergen.com"
    "cardinalhealth.com" "redhat.com" "exxonmobil.com" "walgreensbootsalliance.com" "costco.com"
    "empire.ca" "hcaholdings.com" "intactfc.com" "np.edu.sg" "nvidia.com" "powercorporation.com"
    "ntu.ac.uk" "wegmans.com" "microfocus.com" "booking.com" "danas.rs" "tesoro.com" "cvshealth.com"
    "blackberry.com" "johnsonandjohnson.com" "delltechnologies.com" "schwab.com" "lyft.com"
    "airbus.com" "infineon.com" "shell.com" "hpe.com" "intuitive.com" "procterandgamble.com" "zdf.de"
)

# 随机抽取一个 SNI
SNI=$(printf "%s\n" "${DOMAIN_LIST[@]}" | shuf -n 1)
# ==========================================

# 1. 环境准备
apt update && apt install -y curl openssl jq sed

# 2. 安装 Xray
echo "正在安装 Xray..."
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# 3. 准备自签名证书 (使用随机抽取的 SNI)
echo "随机选中的伪装域名 (SNI): $SNI"
mkdir -p /etc/xray/cert
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/xray/cert/server.key -out /etc/xray/cert/server.crt \
-subj "/CN=$SNI"
chmod 644 /etc/xray/cert/server.*

# 4. 写入配置 (Trojan 协议)
cat <<EOF > /usr/local/etc/xray/config.json
{
    "log": { "loglevel": "info" },
    "inbounds": [{
        "port": $PORT,
        "protocol": "trojan",
        "settings": { "clients": [ { "password": "$CUSTOM_PASS" } ] },
        "streamSettings": {
            "network": "tcp",
            "security": "tls",
            "tlsSettings": {
                "certificates": [{
                    "certificateFile": "/etc/xray/cert/server.crt",
                    "keyFile": "/etc/xray/cert/server.key"
                }]
            }
        }
    }],
    "outbounds": [{ "protocol": "freedom" }]
}
EOF

# 5. 放行防火墙并重启
iptables -I INPUT -p tcp --dport $PORT -j ACCEPT
systemctl restart xray
sleep 2

# 6. 生成链接
IP=$(curl -s https://api64.ipify.org)
RAW_LINK="trojan://$CUSTOM_PASS@$IP:$PORT?sni=$SNI&allowInsecure=1#Xray_Trojan_$SNI"

# 7. 纯文本安全推送 (通过 urlencode 确保 100% 成功)
echo "正在推送信息至 Telegram..."
MSG="✅ Trojan 部署成功！

服务器 IP: $IP
连接密码: $CUSTOM_PASS
随机 SNI: $SNI
端口: $PORT

节点链接:
$RAW_LINK"

RESPONSE=$(curl -s -X POST "https://api.telegram.org/bot$TG_TOKEN/sendMessage" \
    --data-urlencode "chat_id=$TG_CHAT_ID" \
    --data-urlencode "text=$MSG")

# 8. 状态反馈
if echo "$RESPONSE" | grep -q '"ok":true'; then
    echo "-------------------------------------------------------"
    echo "部署完成！SNI: $SNI"
    echo "消息已成功推送到 Telegram。"
    echo "-------------------------------------------------------"
else
    echo "-------------------------------------------------------"
    echo "部署完成，但推送失败。"
    echo "错误详情: $RESPONSE"
    echo "手动链接: $RAW_LINK"
    echo "-------------------------------------------------------"
fi