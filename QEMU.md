---
tags:
---
-- **Установка**
```bash
sudo apt update
sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
```

-- **Запуск**
```bash
qemu-system-x86_64 -boot d -cdrom ubuntu-25.04-live-server-amd64.iso -m 4G -enable-kvm
```