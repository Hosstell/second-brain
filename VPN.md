### Server side
REPO: https://github.com/MHSanaei/3x-ui

**Fast install:**
```bash
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
```

**Connection settings:**
- Протокол: vless
- Безопасность: TLS
- Нажать на "Установить сертификат панели"
### Client side
Client: cli **v2ray**

**/etc/v2ray/config.json**
```
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
            "address": "144.31.199.155",
            "port": 46551,
            "users": [
              {
                "id": "71b00c42-4c21-4650-a367-3416861fe86c",
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