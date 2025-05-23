
### Общая информации о системе

➜ ~ **lsb_release -a** 
```
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 24.04.2 LTS
Release:	24.04
Codename:	noble
```

➜  ~ **cat /etc/os-release** 
```
PRETTY_NAME="Ubuntu 24.04.2 LTS"
NAME="Ubuntu"
VERSION_ID="24.04"
VERSION="24.04.2 LTS (Noble Numbat)"
VERSION_CODENAME=noble
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=noble
LOGO=ubuntu-logo
```

➜  ~ **uname -a** 
```
Linux andrey-Latitude-5420 6.11.0-26-generic #26~24.04.1-Ubuntu SMP PREEMPT_DYNAMIC Thu Apr 17 19:20:47 UTC 2 x86_64 x86_64 x86_64 GNU/Linux
```

➜  ~ **uptime** 
```
 16:22:39 up  1:07,  1 user,  load average: 0,32, 0,59, 0,63
```

➜  ~ **whoami** 
```
andrey
```


### Информация о железе

**lshw** - подробная информацию о конфигурации оборудования.
**lscpu** - отображает информацию об архитектуре процессора
**lsblk** - список блочных устройств
**lspci** - список всех PCI-устройств
**lsusb** - список USB-устройств

### Информация о использовании памяти и ЦП

➜  ~ **free -h**
```
			   всего       занят        своб       общая   буф/врем.    доступно
Память:         30Gi       5,7Gi        20Gi       1,5Gi       6,9Gi        25Gi
Подкачка:      8,0Gi          0B       8,0Gi
```
Команда `vmstat` также покажет статистику по памяти.

**top** — это как Диспетчер задач в Linux: он отображает процессы и использование ресурсов. 
**htop** — это интерактивная и более приятная версия.

### Информации о использование диска

➜  ~ **df -h**        
```
Файл.система   Размер Использовано  Дост Использовано% Cмонтировано в
tmpfs            3,1G         3,0M  3,1G            1% /run
/dev/nvme0n1p2   468G         260G  185G           59% /
tmpfs             16G          35M   16G            1% /dev/shm
tmpfs            5,0M         8,0K  5,0M            1% /run/lock
efivarfs         374K         290K   80K           79% /sys/firmware/efi/efivars
tmpfs             16G            0   16G            0% /run/qemu
/dev/nvme0n1p1   1,1G         6,2M  1,1G            1% /boot/efi
tmpfs            3,1G         356K  3,1G            1% /run/user/1000
```

**du -h** - Если вы хотите оценить размер папок.