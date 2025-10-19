яhttps://firstvds.ru/technology/ustanovka-openvpn#p1616132650625_6
#### RUN
```bash
docker run \
	--name openvpn \
	--restart on-failure \
	--cap-add=NET_ADMIN \
	-p 1194:1194/udp \
	-p 80:8080/tcp \
	-e HOST_ADDR=$(curl -s https://api.ipify.org) \
	-d \
	alekslitvinenk/openvpn
	
	
docker run -d \
  --name myvpn \
  --restart on-failure \
  --cap-add=NET_ADMIN \
  -p 443:443/tcp \
  -p 80:8080/tcp \
  -e PORTS="443" \
  -e PROTO=tcp \
  -e HOST_ADDR=$(curl -s https://api.ipify.org) \
  alekslitvinenk/openvpn
  
  
DOCKOVPN_CONFIG_PORT=81
DOCKOVPN_TUNNEL_PORT=443
DOCKOVPN_TUNNEL_PROTOCOL=tcp
docker run -it --rm --cap-add=NET_ADMIN \
-p $DOCKOVPN_TUNNEL_PORT:1194/$DOCKOVPN_TUNNEL_PROTOCOL -p $DOCKOVPN_CONFIG_PORT:8080/tcp \
-e HOST_CONF_PORT="$DOCKOVPN_CONFIG_PORT" \
-e HOST_TUN_PORT="$DOCKOVPN_TUNNEL_PORT" \
-e HOST_TUN_PROTOCOL="$DOCKOVPN_TUNNEL_PROTOCOL" \
--name myvpn alekslitvinenk/openvpn
```


### Для использования через мобильный интеренет
```bash
#!/bin/bash

set -e

# === Настройки ===
SERVER_PORT=443
PROTOCOL=tcp
VPN_DIR="/etc/openvpn"
EASYRSA_DIR="/etc/openvpn/easy-rsa"
CLIENT_NAME="client1"
OUTPUT_DIR="$HOME/ovpn-client"
OVPN_FILE="$OUTPUT_DIR/$CLIENT_NAME.ovpn"

# === Установка зависимостей ===
echo "📦 Установка OpenVPN и easy-rsa..."
apt update && apt install -y openvpn easy-rsa curl

# === Получение внешнего IP ===
SERVER_IP=$(curl -s https://api.ipify.org)
echo "🌐 Внешний IP сервера: $SERVER_IP"

# === Инициализация easy-rsa PKI ===
echo "🔐 Инициализация PKI..."
make-cadir "$EASYRSA_DIR"
cd "$EASYRSA_DIR"
./easyrsa init-pki
echo -ne "\n" | ./easyrsa build-ca nopass
./easyrsa gen-req "$CLIENT_NAME" nopass
./easyrsa sign-req client "$CLIENT_NAME"
./easyrsa gen-dh
openvpn --genkey --secret "$EASYRSA_DIR/ta.key"
./easyrsa gen-req server nopass
./easyrsa sign-req server server

# === Копирование файлов на место ===
echo "📁 Настройка конфигурации сервера..."
cp pki/ca.crt pki/private/server.key pki/issued/server.crt "$VPN_DIR"
cp "$EASYRSA_DIR/ta.key" "$VPN_DIR"
cp pki/dh.pem "$VPN_DIR"

# === Создание server.conf ===
cat > "$VPN_DIR/server.conf" <<EOF
port $SERVER_PORT
proto $PROTOCOL
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
auth SHA256
tls-auth ta.key 0
topology subnet
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
keepalive 10 120
cipher AES-256-CBC
persist-key
persist-tun
status openvpn-status.log
verb 3
explicit-exit-notify 1
EOF

# === Разрешение IP пересылки и NAT ===
echo "🛠 Настройка IP forwarding..."
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/^#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf

iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $(ip route show default | awk '/default/ {print $5}') -j MASQUERADE
apt install -y iptables-persistent

# === Запуск OpenVPN-сервера ===
echo "🚀 Запуск OpenVPN-сервера..."
systemctl enable openvpn@server
systemctl start openvpn@server

# === Создание .ovpn файла ===
echo "📦 Создание клиентского .ovpn файла..."

mkdir -p "$OUTPUT_DIR"
cat > "$OVPN_FILE" <<EOF
client
dev tun
proto $PROTOCOL
remote $SERVER_IP $SERVER_PORT
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
auth SHA256
key-direction 1
verb 3

<ca>
$(cat $EASYRSA_DIR/pki/ca.crt)
</ca>
<cert>
$(cat $EASYRSA_DIR/pki/issued/$CLIENT_NAME.crt)
</cert>
<key>
$(cat $EASYRSA_DIR/pki/private/$CLIENT_NAME.key)
</key>
<tls-auth>
$(cat $EASYRSA_DIR/ta.key)
</tls-auth>
EOF

echo "✅ Готово!"
echo "➡️  Используй файл: $OVPN_FILE для подключения к серверу OpenVPN"

```




```bash
docker run --name openvpn --cap-add=NET_ADMIN -p 1194:1194/udp -v /etc/openvpn:/etc/openvpn -e "EASYRSA_CERT_EXPIRE=3650" -e "EASYRSA_REQ_COUNTRY=RU" -e "EASYRSA_REQ_PROVINCE=Moscow" -e "EASYRSA_REQ_CITY=Moscow" -e "EASYRSA_REQ_ORG=YourOrg" -e "EASYRSA_REQ_EMAIL=admin@example.com" -e "EASYRSA_REQ_OU=MyOrgUnit" -e "EASYRSA_ALGO=ec" -e "EASYRSA_DIGEST=sha512" -e "USE_TLS_CRYPT=yes" -e "TLS_CRYPT_V2=yes" -d alekslitvinenk/openvpn
```