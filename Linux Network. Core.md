-- **Список интерфейсов**
```bash
ip addr show

"""
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: enp0s31f6: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc fq_codel state DOWN group default qlen 1000
    link/ether a0:29:19:0d:f0:7e brd ff:ff:ff:ff:ff:ff
3: wlp0s20f3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 7c:70:db:31:fc:ef brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.103/24 brd 192.168.0.255 scope global noprefixroute wlp0s20f3
       valid_lft forever preferred_lft forever
    inet6 fe80::f162:d70b:270c:1590/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever

"""
```
-- **Список роутов**
```bash
ip route show

"""
default via 192.168.0.1 dev wlp0s20f3 proto dhcp src 192.168.0.103 metric 600 
10.0.3.0/24 dev lxcbr0 proto kernel scope link src 10.0.3.1 linkdown 
10.0.85.2 dev outline-tun0 scope link src 10.0.85.1 linkdown 
172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1 
172.18.0.0/16 dev br-c0750fac11ea proto kernel scope link src 172.18.0.1 linkdown 
192.168.0.0/24 dev wlp0s20f3 proto kernel scope link src 192.168.0.103 metric 600 
192.168.122.0/24 dev virbr0 proto kernel scope link src 192.168.122.1 linkdown 
"""
```

-- **Как читать интерфейсы?**
