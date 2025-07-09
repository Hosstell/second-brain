#!/bin/bash

set -e

echo "📦 Устанавливаем зависимости..."
sudo apt install -y git make gcc systemd

echo "⬇️ Клонируем и устанавливаем keyd..."
if [ -d /tmp/keyd ]; then
    sudo rm -rf /tmp/keyd
fi

git clone https://github.com/rvaiya/keyd.git /tmp/keyd
cd /tmp/keyd    
make
sudo make install
sudo systemctl enable keyd
sudo systemctl start keyd

echo "🛠 Создаём/обновляем скрипт переключения раскладки..."
sudo tee /usr/local/bin/toggle_layout.sh > /dev/null << 'EOF'
current=$(ibus engine)

if [[ "$current" == *us* ]]; then
    ibus engine xkb:ru::rus
else
    ibus engine xkb:us::eng
fi
EOF

sudo chmod +x /usr/local/bin/toggle_layout.sh

echo "🧩 Создаём/обновляем конфиг keyd (Alt+Shift для смены языка)..."
sudo tee /etc/keyd/default.conf > /dev/null << 'EOF'
[ids]
*

[main]
leftalt + leftshift = cmd:/usr/local/bin/toggle_layout.sh
EOF

echo "🔁 Перезапускаем keyd..."
sudo systemctl restart keyd

echo "✅ Установка завершена!"
echo "🔤 Теперь Alt+Shift переключает раскладку ввода (через D-Bus)."
