#### Без TLS
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
```
#### С TLS
```bash
# том для конфигов/PKI
docker volume create ovpn-data

# сгенерировать базовый конфиг (замени YOUR_IP/DOMAIN и порт при желании)
docker run --rm -v ovpn-data:/etc/openvpn kylemanna/openvpn \
  ovpn_genconfig -u udp://YOUR_IP_OR_DOMAIN:1194

# инициализировать PKI (задаст пароль для CA)
docker run -it --rm -v ovpn-data:/etc/openvpn kylemanna/openvpn ovpn_initpki

# Включаем tls-crypt (меняем дефолтный tls-auth)
# если ta.key вдруг не создан — создадим
docker run --rm -v ovpn-data:/etc/openvpn kylemanna/openvpn \
  bash -lc 'test -f /etc/openvpn/pki/ta.key || openvpn --genkey --secret /etc/openvpn/pki/ta.key'

# правим серверный конфиг: tls-auth -> tls-crypt и убираем key-direction
docker run --rm -v ovpn-data:/etc/openvpn kylemanna/openvpn \
  bash -lc "sed -i 's#^tls-auth .*#tls-crypt /etc/openvpn/pki/ta.key#' /etc/openvpn/openvpn.conf; sed -i '/^key-direction/d' /etc/openvpn/openvpn.conf"
  
docker run -d --name openvpn-tls \
  --restart unless-stopped \
  --cap-add=NET_ADMIN --device /dev/net/tun \
  -p 1194:1194/udp \
  -v ovpn-data:/etc/openvpn \
  kylemanna/openvpn


# создаём сертификат клиента (замени на нужное имя)
export CLIENT=client-tls
docker run -it --rm -v ovpn-data:/etc/openvpn kylemanna/openvpn \
  easyrsa build-client-full $CLIENT

# генерим профиль
docker run --rm -v ovpn-data:/etc/openvpn kylemanna/openvpn \
  ovpn_getclient $CLIENT > ${CLIENT}.ovpn

sed -i 's/<tls-auth>/<tls-crypt>/' ${CLIENT}.ovpn
sed -i 's#</tls-auth>#</tls-crypt>#' ${CLIENT}.ovpn
sed -i '/^key-direction/d' ${CLIENT}.ovpn
```