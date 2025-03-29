##### zsh
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
##### batcat
```bash
sudo apt install -y bat
echo "\nalias cat='batcat'\n" >> ~/.zshrc
```
#### настройка подключения к серверу по ssh без пароля
```bash
ssh-keygen # если нужно 
ssh-copy-id login@host
```

отключение возможности авторизации на сервере по паролю 