Homelab projemdeki uygulamalara ve sisteme uzaktan erisebilmek icin kendime bir adet OpenVPN serveri kurdum. Bazi sebeplerden dolayi OpenVPN tercih ediyorum, bu tarz bir senaryoda sizlere WireGuard tavsiye ederim.

Kurulum islemlerini Debian 12 uzerinde gerceklestiriyorum.(LXC Container)

# OpenVPN Server Kurulumu

1. OpenVPN ve EasyRSA kurulumlari yapilir.
```
apt update && apt upgrade -y
```

```
apt install openvpn easy-rsa -y
```

2. OpenVPN baglantilar icin sertifikalara ihtiyac duydugu icin rasy rsa ile bir sertifika olusturmamiz gerekecek. Bunun icin once CA(Sertifika Otoritesi) olusturmamiz gerekiyor.

```
make-cadir /etc/openvpn/easy-rsa
cd /etc/openvpn/easy-rsa
```

Bu dizinde ```vars``` adinda bir dosya olusturup ayarlamalari ekleyelim:

```
vim vars
```

```
set_var EASYRSA_REQ_COUNTRY    "TR"
set_var EASYRSA_REQ_PROVINCE   "Ankara"
set_var EASYRSA_REQ_CITY       "Ankara"
set_var EASYRSA_REQ_ORG        "MyVPN"
set_var EASYRSA_REQ_EMAIL      "ben@berkbal.com.tr"
set_var EASYRSA_REQ_OU         "IT"
set_var EASYRSA_KEY_SIZE       2048
```