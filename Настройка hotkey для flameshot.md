**Установка**
`apt install flameshot`

**Скрипт**
`nano flameshot.sh`
```
#!/bin/bash
export QT_SCREEN_SCALE_FACTORS="1;1.5"
/usr/bin/flameshot gui
```

**Запуск** 
`bash /home/user/tools/flameshot.sh`