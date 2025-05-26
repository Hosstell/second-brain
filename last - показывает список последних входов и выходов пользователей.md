### `last` - успешные входы:
```bash
$ last
alex     pts/0        192.168.1.10     Fri May 24 10:01   still logged in
john     pts/1        192.168.1.15     Fri May 24 09:45 - 10:00  (00:15)
reboot   system boot  5.15.0-105-generic Fri May 24 09:30   still running
```

**Примеры:**
```bash
last  # Показать всех последних вошедших пользователей
last -n 5  # Показать последние 5 входов
last alex  # Показать входы конкретного пользователя (например, "alex")
last -s 2024-01-01 -t 2024-01-31  # Показать логины за определённый период (например, с 2024-01-01 по 2024-01-31)
last -F  # Показать полные даты и время входа/выхода
```

### `lastb` - неудачные попытки входа:
```bash
$ sudo lastb
UNKNOWN  tty1                          Fri May 24 08:52 - 08:52  (00:00)
root     ssh:notty    192.168.1.50     Fri May 24 08:51 - 08:51  (00:00)
john     ssh:notty    192.168.1.51     Thu May 23 22:15 - 22:15  (00:00)

btmp begins Wed May 22 14:22:44 2024
```

### `lastlog` — последний вход всех пользователей:
```bash
$ lastlog
Username         Port     From             Latest
root                                       **Never logged in**
daemon                                     **Never logged in**
john             pts/1    192.168.1.15     Fri May 24 09:45:01 +0000 2024
alex             pts/0    192.168.1.10     Fri May 24 10:01:33 +0000 2024
nobody                                     **Never logged in**
```

