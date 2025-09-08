# Rhel'de Firewall

RHEL’de firewall, `firewalld` servisi ile yönetilen dinamik bir paket filtreleme sistemidir. Her `ağ arayüzü bir zone altında` toplanır ve zone’lar servisler, `portlar` ve `kurallarla` kontrol edilir. Kurallar geçici veya kalıcı `(--permanent)` olarak eklenebilir ve `firewall-cmd` komutu ile yönetilir.

## firewall-cmd

Bütün paketleri droplamak için `default` zone'u `public` isimli zone'a çevirebiliriz. İzin vermek istediğimiz portlara kural yazarız.


```bash
firewall-cmd --set-default-zone=public
```

Örnek: 22 ve 80 ve 8080'i **kalıcı** olarak aktifleştirmek. `--permanent` ile kalıcı olarak kural eklenir. 

```bash
firewall-cmd --zone=public --add-port=22/tcp --permanent
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=8080/tcp --permanent
```

Firewall-cmd'yi reloadlamak:

```bash
firewall-cmd --reload
```

## Belli bir Zone'u Bir Interface'e Bind Etmek

Belli bir kural seti (zone) belli bir network interfaceine aşağıdaki gibi eklenebilir.

```bash
firewall-cmkd --zone=public --add-interface=eno192
```

Zone'un bilgilerine erişip hangi interfacelere bind edildiği öğrenilebilir.

```bash
firewall-cmd --zone=public --list-all
```