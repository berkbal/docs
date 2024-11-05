# Libvirt KVM'ye Gercek Ip Adresi Ekleme Islemi

Bu işlemi gerçekleştirmek için ```virsh edit``` komutu ile olusturulan sanal makineye yeni bir interface ekleyip bu interface uzerinden ip adresini tanimlayabiliriz.

## Dikkat Edilmesi Gerekenler

1. Sunucuya verilmek istenen ip adresinin başka bir yerde kullanımda olmaması gerekmektedir. Hypervisor üzerindeki iptables kuralları ve aynı yerde olan diğer makinelerdeki iptables kuralları kontrol edilmelidir.

2. Sunucunun bu ip adresini kullanabilmesi için öntanımlı gateway olarak yeni eklenen interface gatewayi kullanılmalıdır.

## Sanal Makineye yeni bir Interface Eklenmesi

```
virsh edit python
```

Aşağıdaki satırlar makinede var olan interface tanımının altına eklenmelidir.

```
<interface type='bridge'>
    <mac address='00:50:56:00:ad:dc'/>
    <source bridge='br0'/>
    <model type='virtio'/>
    <address type='pci' domain='0x0000' bus='0x00' slot='0x08' function='0x0'/>
</interface>
```

Bu işlem gerçekleştirildikten sonra sanal makine reboot edilmelidir. Reboot edildikten sonra makine üzerinde yeni bir interface oluşmuş olmalı. Bu interface için bir ip adresi tanımlaması yapılması gerekiyor.

```
auto ens?
iface ens? inet static
        address IP ADRESI
        gateway GATEWAY?
        netmask Subnet
        hwaddress ether MAC-ADRESI(Makineye bu interface eklenirken kullanilan mac adresi)
```

### Örnek interfaces dosyası

```
auto ens3
iface ens3 inet static
	address LOCAL-STATIK
	netmask 255.255.255.0
    #gateway LOCAL-GATEWAY # Gateway tanimini ip adresini verdigimiz interface icin yapiyoruz.


auto ens11
iface ens11 inet static
	address VERMEK ISTEDIGIMIZ IP /?
	netmask SUBNET
	gateway GATEWAY
	hwaddress ether MAC-ADRESI(Makineye bu interface eklenirken kullanilan mac adresi)
root@python:~# 
```

Sunucunun public ip adresini test etmek için aşağıdaki komut kullanılabilir.

```
dig +short myip.opendns.com @resolver1.opendns.com
```