# Сетевой интерфейс и его устройство
В ядре Linux каждое сетевое интерфейс-устройство — это объект _netdevice_.
- **Физические** (префикс `eth0`, `wlan0`) - «Железная» карта, Wi-Fi, USB-NIC
- **Логические** (префикс `lo`) - loopback
- **Виртуальные** (префикс `veth0`, `br0`, `tun0`…) - Создаёт ядро по вашей команде
#### Основные типы виртуальных интерфейсов
- **dummy**  
    • назначение — «пустой» интерфейс для тестов, сервис-IP  
    • создать: `ip link add dummy0 type dummy`
- **veth**  
    • назначение — пара взаимосвязанных интерфейсов (контейнер ↔ хост)  
    • создать: `ip link add veth0 type veth peer name veth1`
- **bridge**  
    • назначение — программный L2-коммутатор, объединяющий порты  
    • создать: `ip link add br0 type bridge`
- **VLAN**  
    • назначение — VLAN-тегирование на существующем интерфейсе  
    • создать: `ip link add link eth0 name eth0.100 type vlan id 100`
- **bond / team**  
    • назначение — агрегация каналов (LACP, резервирование)  
    • создать: `ip link add bond0 type bond mode 802.3ad`
- **macvlan**  
    • назначение — «клон» с отдельным MAC на той же физической карте  
    • создать: `ip link add mac0 link eth0 type macvlan mode bridge`
- **tun / tap**  
    • назначение — L3- (TUN) или L2- (TAP) туннели для VPN и прочего  
    • создать: `ip tuntap add dev tun0 mode tun`
- **wireguard**  
    • назначение — шифрованный L3-туннель WireGuard  
    • создать: `ip link add wg0 type wireguard` (затем настроить `wg set …`)
- **gre / gretap**  
    • назначение — GRE-туннель (L3) или gretap (L2)  
    • создать: `ip link add gre1 type gre remote 203.0.113.1 local 198.51.100.1`
- **vxlan**  
    • назначение — L2-оверлей поверх L3 (часто в Kubernetes/облаках)  
		    • создать: `ip link add vxlan10 type vxlan id 10 dstport 4789 dev eth0`
- **vrf**  
    • назначение — изолированная таблица маршрутов (VRF)  
    • создать: `ip link add vrf-blue type vrf table 10`

