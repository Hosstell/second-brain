## Server side
REPO: https://github.com/MHSanaei/3x-ui

**Fast install:**
```bash
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
```

**Connection settings:**
- Протокол: vless
- Безопасность: TLS
- Нажать на "Установить сертификат панели"
## Client side
Client: cli **v2ray**

**/etc/v2ray/config.json**
```json
{
  "inbounds": [
    {
      "port": 10808,
      "listen": "127.0.0.1",
      "protocol": "socks",
      "settings": {
        "auth": "noauth",
        "udp": true
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls"]
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "vless",
      "settings": {
        "vnext": [
          {
            "address": "SERVER_API",   <-- 
            "port": PORT,  <--
            "users": [
              {
                "id": "CLIENT_UUID",  <-- 
                "encryption": "none",
                "level": 0,
                "flow": ""
              }
            ]
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "tls",
        "tlsSettings": {
          "serverName": "",
          "fingerprint": "chrome",
          "alpn": ["h2", "http/1.1"]
        },
        "sockopt": {
          "tcpFastOpen": true
        }
      },
      "tag": "proxy"
    }
  ],
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": []
  }
}
```

#### run **v2ray**
```bash
snap install v2ray-core

systemctl status v2ray
```

#### Настраиваем proxy
Для GNOME

1. Настройки VPN и Proxy
2. Прокси сервер
3. Конфигурация: Ручная
4. Хост SOCKS. 
	1. URL - 127.0.0.1
	2. PORT - 10808
5. Игнорируемые узлы. Удаляем значение
6. У всех остальных значениях URL - Удалям