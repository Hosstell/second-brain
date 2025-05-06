##### zsh
```bash
sudo apt install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
##### batcat
```bash
sudo apt install -y bat
echo 'alias cat="batcat"' >> ~/.zshrc
echo 'alias catd="batcat --theme Coldark-Cold"' >>  ~/.zshrc
```
##### eza
```bash
sudo apt install eza -y

echo 'alias ls="eza"' >> ~/.zshrc
echo 'alias ll="eza -la"' >> ~/.zshrc
```
##### Gogh (темы для консоли)
```bash
bash -c  "$(wget -qO- https://git.io/vQgMr)" 
```
 -> Everforest Dark Hard (125)
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

#### ps - просмотр процессов
Просмотреть все процессы с их подпроцессами 
```bash
ps -auxwf
```

#### wall
Отправляем сообщения в stdout другим пользователям терминала

##### copy
```bash
sudo apt install xclip -y
echo 'alias copy="xclip -sel c <"' >> ~/.zshrc

copy filename.txt
```


