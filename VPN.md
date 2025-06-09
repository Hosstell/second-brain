```bash
#!/bin/bash

# Проверка, что скрипт выполняется с правами суперпользователя
if [ "$EUID" -ne 0 ]; then
  echo "Пожалуйста, запустите скрипт с правами суперпользователя."
  exit
fi

# Обновление системы
apt-get update
apt-get upgrade -y

# Установка OpenVPN и Easy-RSA
apt-get install -y openvpn easy-rsa

# Создание каталога для Easy-RSA
make-cadir ~/openvpn-ca
cd ~/openvpn-ca

# Настройка переменных
cat > vars << EOF
set_var EASYRSA_REQ_COUNTRY    "RU"
set_var EASYRSA_REQ_PROVINCE   "Moscow"
set_var EASYRSA_REQ_CITY       "Moscow"
set_var EASYRSA_REQ_ORG        "MyOrg"
set_var EASYRSA_REQ_EMAIL      "email@example.com"
set_var EASYRSA_REQ_OU         "MyOrgUnit"
EOF

# Инициализация PKI и создание CA
./easyrsa init-pki
./easyrsa build-ca nopass

# Создание серверного ключа и сертификата
./easyrsa gen-req server nopass
./easyrsa sign-req server server

# Создание ключа Diffie-Hellman
./easyrsa gen-dh

# Создание клиентского ключа и сертификата
./easyrsa gen-req client1 nopass
./easyrsa sign-req client client1

# Создание ключа HMAC
openvpn --genkey --secret ta.key

# Копирование файлов в директорию OpenVPN
cp pki/ca.crt pki/issued/server.crt pki/private/server.key pki/dh.pem ta.key /etc/openvpn

# Создание конфигурационного файла сервера
cat > /etc/openvpn/server.conf << EOF
port 1194
proto udp
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
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
verb 3
explicit-exit-notify 1
EOF

# Настройка IP-трансляции
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p

# Настройка брандмауэра
sudo apt-get install ufw -y
ufw allow 1194/udp
ufw allow OpenSSH
ufw disable
ufw enable

# Перезапуск OpenVPN
systemctl start openvpn@server
systemctl enable openvpn@server

# Создание клиентского конфигурационного файла
cat > ~/client1.ovpn << EOF
client
dev tun
proto udp
remote YOUR_SERVER_IP 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
auth SHA256
cipher AES-256-CBC
key-direction 1
verb 3
<ca>
$(cat ~/openvpn-ca/pki/ca.crt)
</ca>
<cert>
$(cat ~/openvpn-ca/pki/issued/client1.crt)
</cert>
<key>
$(cat ~/openvpn-ca/pki/private/client1.key)
</key>
<tls-auth>
$(cat ~/openvpn-ca/ta.key)
</tls-auth>
EOF

echo "OpenVPN установлен и настроен. Клиентский файл ~/client1.ovpn создан."
echo "Не забудьте заменить YOUR_SERVER_IP на IP-адрес вашего сервера в клиентском файле."
```