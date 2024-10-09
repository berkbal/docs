![wireguard logo](wireguard.png)

# Wireguard Sunucu Kurulumu

Kişisel kullanım için kullanıma hazır bir wireguard sunucu konteyneridir. Hızlı kullanım için eşleri ve yapılandırma dosyalarını otomatik olarak oluşturur. Konteyneri kurmadan önce düzenlemeniz gereken yalnızca 2 değişken vardır.

Wireguard'in kernel modüllerini sistemimize aşağıdaki komut ile kurup container için compose dosyasını editledikten sonra ayağa kaldırabiliriz.

```
apt-get update ; apt-get install wireguard-tools
```

## Docker-Compose Dosyası

```
version: '3.7'
services:
  wireguard:
    image: linuxserver/wireguard
    container_name: wireguard
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Turkey/Istanbul # timezone
      - SERVERPORT=51820 # wireguard server portu
      - PEERS=5 #optional
      - PEERDNS=auto #optional
      - ALLOWEDIPS=0.0.0.0/0 # Baglantiya izin verilen subnetler
      - INTERNAL_SUBNET=10.13.13.0/24 # Wireguard Subneti
      - SERVERURL= # Public IP
    volumes:
      - ./config:/config
      - /usr/src:/usr/src # location of kernel headers
      - /lib/modules:/lib/modules
    ports:
      - 51820:51820/udp
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
    restart: always
```

18 ve 14. satırları düzenlemek gerekmektedir. 18. satıra public IP adresini, 14. satıra ise sunucunuzda kaç istemci olmasını istediğinizi belirten bir sayı yazın.

Not: Sistemde bir firewall var ise WireGuard'ın kullandığı porta izin vermek gerekmektedir. Kullanılan port 51820 olarak belirlenmiştir.(Wireguard'ın default portu) İsteğe göre bu compose dosyasından düzenlenebilir.