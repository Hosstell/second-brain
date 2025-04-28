**`libvirt`** — это библиотека и набор инструментов для управления виртуализацией. Она предоставляет API для взаимодействия с различными гипервизорами, включая **QEMU**, **Xen**, **LXC** и другие. Когда вы создаете или запускаете ВМ через `libvirt`, он генерирует команды для **QEMU** (или другого гипервизора) и передает их на выполнение.

- **`virsh`** — командная строка для управления ВМ.
- **`virt-manager`** — графический интерфейс для управления ВМ.

### Запуск VM
1. **Создайте XML-конфигурацию для ВМ:** 
   Создайте файл `vm.xml` с конфигурацией вашей ВМ:
```xml
<domain type='kvm'>
  <name>myvm</name>
  <memory unit='GiB'>1</memory>
  <vcpu placement='static'>1</vcpu>
  <os>
    <type arch='x86_64' machine='pc'>hvm</type>
    <boot dev='hd'/>
  </os>
  <devices>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='/path/to/disk.qcow2'/>
      <target dev='vda' bus='virtio'/>
    </disk>
    <interface type='network'>
      <mac address='52:54:00:6b:5e:4a'/>
      <source network='default'/>
      <model type='virtio'/>
    </interface>
  </devices>
</domain>
```
2. **Определите ВМ в `libvirt`:**
```bash
virsh define vm.xml
```
3. **Запустите ВМ:**
```bash
virsh start myvm
```
4. **Проверьте состояние ВМ:**
```bash
virsh list --all

"""
 Id   Name   State
-----------------------
 -    vm1    shut off
 -    vm2    shut off
"""
```  

**Trouble shooting**