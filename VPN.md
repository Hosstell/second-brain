```bash

```

#### RUN
```bash
docker run \
	--name dockovpn \
	--restart on-failure \
	--cap-add=NET_ADMIN \
	-p 1194:1194/udp \
	-p 80:8080/tcp \
	-e HOST_ADDR=$(curl -s https://api.ipify.org) \  
	alekslitvinenk/openvpn
```