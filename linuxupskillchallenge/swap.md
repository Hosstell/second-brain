### swappiness
Параметр **swappiness** (0–100) управляет тем, как активно ядро использует swap.
- `0` — использовать swap только в крайнем случае
- `100` — агрессивно выгружать память в swap
- По умолчанию в Ubuntu: 60
- Рекомендуется: 10 (для настольных систем)

**Изменение временно:**
```bash
sudo sysctl vm.swappiness=10
```

**Постоянно:**
```bash
gksudo gedit /etc/sysctl.conf 
# Добавьте:
vm.swappiness=10
```

Каждому swap-разделу или файлу назначается приоритет.  
➜  ~  **cat /proc/swaps**
```
Filename        Type     Size   Used    Priority
/swap.img       file  8388604      0          -2
```
