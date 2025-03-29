```bash
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-compose
sudo rm -rf /etc/bash_completion.d/docker /usr/local/bin/docker-compose /etc/bash_completion.d/docker-compose
sudo apt install containerd -y
sudo apt install -y docker.io docker-compose-v2
```