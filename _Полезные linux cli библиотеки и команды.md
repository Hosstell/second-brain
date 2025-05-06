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
`Отправляем сообщения в stdout другим пользователям терминала`
##### copy
```bash
sudo apt install xclip -y
echo 'alias copy="xclip -sel c <"' >> ~/.zshrc

copy filename.txt
```
#### Какие регистри apt update использует
```bash
➜ ll /etc/apt/sources.list.d/            
.rw-r--r-- 1,8k root 24 ноя  2024 deadsnakes-ubuntu-ppa-noble.sources
.rw-r--r--  112 root 24 ноя  2024 docker.list
.rw-r--r--  151 root  3 мар 15:00 protonvpn-stable.sources
.rw-r--r-- 1,8k root 24 ноя  2024 pypy-ubuntu-ppa-noble.sources
.rw-r--r--  296 root 24 ноя  2024 steam-beta.list
.rw-r--r--  228 root 24 ноя  2024 steam-stable.list
.rw-r--r--  386 root 24 ноя  2024 ubuntu.sources
.rw-r--r-- 2,6k root 27 авг  2024 ubuntu.sources.curtin.orig
.rw-r--r--  187 root 24 ноя  2024 vivaldi.list
.rw-r--r--  204 root 19 апр 12:23 vscode.list
.rw-r--r--   84 root  8 дек  2024 waydroid.list
.rw-r--r--  156 root 30 апр 10:24 windsurf.list
➜ sudo rm /etc/apt/sources.list.d/protonvpn-stable.sources 
```
