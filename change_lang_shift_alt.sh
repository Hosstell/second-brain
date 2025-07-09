#!/bin/bash

set -e

echo "📦 Устанавливаем зависимости..."
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

# Получаем текущую активную раскладку
index=$(gsettings get org.gnome.desktop.input-sources current)

# Инвертируем
if [ "$index" = "uint32 0" ]; then
    new_index=1
else
    new_index=0
fi

# Меняем через D-Bus (этот вызов реально активирует нужную раскладку)
gdbus call --session \
  --dest org.gnome.Shell \
  --object-path /org/gnome/Shell \
  --method org.gnome.Shell.Eval \
  "imports.ui.status.keyboard.getInputSourceManager().inputSources[$new_index].activate()"

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
