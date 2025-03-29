### 1. Настройка сервера
```bash
apt update
apt upgrade -y
apt install docker.io -y && apt install docker-compose -y
```
### 2. Установка GitLab Runner
[ИСТОЧНИК](https://docs.gitlab.com/runner/install/linux-repository.html)

```bash
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
apt install gitlab-runner -y
```

### 3. Регистрация GitLab Runner
[Источник](https://docs.gitlab.com/runner/register/index.html?tab=Linux)

**3.1 Получаем код авторизации в gitlab**
Страница проекта в gitlab → Settings → CI\CD → Runner → New Project Runner. Создаем раннер и получаем токен авторизации

**3.2 Регистрируем раннер на машине**
```bash
sudo gitlab-runner register
```
Вводим название, токен и тип исполнителя. В моем случае shell
### 4. Решаем проблему с правами для пользователя gitlab-runner на сервере
**Ошибка:**
```bash
Install the buildx component to build images with BuildKit:
            https://docs.docker.com/go/buildx/
permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock:
```

**Исправляем:**
```bash
chmod 777 /var/run/docker.sock
```
### 5. Решаем проблему с правами для пользователя gitlab-runner на сервере
**Ошибка:**
```bash
Error saving credentials: error storing credentials - err: exit status 1, 
out: `Cannot autolaunch D-Bus without X11 $DISPLAY`
```

**Исправляем:**
```bash
sudo apt install gnupg2 pass
gpg2 --full-generate-key
```
### 6. Закрыть докер порты от майнеров
```bash
--- # sudo netstat -ntlp
Активные соединения с интернетом (only servers)
Proto Recv-Q Send-Q Local Address Foreign Address State       PID/Program name
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      264/systemd-resolve
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      528/sshd
tcp        0      0 127.0.0.1:39609         0.0.0.0:*               LISTEN      1417/containerd
tcp6       0      0 :::22                   :::*                    LISTEN      528/sshd

--- # root@vds2589:~# sudo lsof -i :39609
COMMAND    PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
container 1417 root   13u  IPv4  23278      0t0  TCP localhost.localdomain:39609 (LISTEN)

--- # kill 1417
```