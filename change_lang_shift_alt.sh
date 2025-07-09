#!/bin/bash

set -e

echo "📦 Устанавливаем зависимости..."
sudo apt update
sudo apt install -y git make gcc systemd

echo "⬇️ Клонируем и устанавливаем keyd..."
git clone https://github.com/rvaiya/keyd.git /tmp/keyd
cd /tmp/keyd
make
sudo make install
sudo systemctl enable keyd
sudo systemctl start keyd

echo "🛠 Создаём скрипт переключения раскладки..."
sudo tee /usr/local/bin/toggle_layout.sh > /dev/null << 'EOF'
#!/bin/bash
layout=$(gsettings get org.gnome.desktop.input-sources current)
if [ "$layout" = "uint32 0" ]; then
    gsettings set org.gnome.desktop.input-sources current 1
else
    gsettings set org.gnome.desktop.input-sources current 0
fi
EOF

sudo chmod +x /usr/local/bin/toggle_layout.sh

echo "🧩 Настраиваем keyd (Alt+Shift для смены языка)..."
sudo tee /etc/keyd/default.conf > /dev/null << 'EOF'
[ids]
*

[main]
leftalt + leftshift = cmd:/usr/local/bin/toggle_layout.sh
EOF

echo "🔁 Перезапускаем keyd..."
sudo systemctl restart keyd

echo "✅ Готово! Теперь Alt+Shift переключает раскладку ввода."
