##### zsh
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

##### batcat
```bash
sudo apt install -y bat
echo "\nalias cat='batcat'\n" >> ~/.zshrc
```

##### exa
репо: https://github.com/ogham/exa
```
echo '\nexport PATH="/home/andrey/tools/exa/bin:$PATH"\n' >> ~/.zshrc
echo '\nalias ll="exa -la"\n' >> ~/.zshrc
echo '\nalias ls="exa"\n' >> ~/.zshrc
```

##### Gogh (темы для консоли)
```bash
bash -c  "$(wget -qO- https://git.io/vQgMr)" 
```
 -> Everforest Dark Hard 

#### настройка подключения к серверу по ssh без пароля
```bash
ssh-keygen # если нужно 
ssh-copy-id login@host
```

**отключение возможности авторизации на сервере по паролю (оставляем только по ключу ssh)**  
Где меняем: `/etc/ssh/sshd_config`
Что меняем: `PasswordAuthebtication yes` на `PasswordAuthebtication no`
Что потом: `sudo service ssh restart`


##### Какой из процессов открыл указанный файл
```bash
lsof filename.txt
```