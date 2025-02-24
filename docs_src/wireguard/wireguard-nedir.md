# Wireguard Nedir?

WireGuard, modern, hızlı, güvenli ve basit bir VPN (Virtual Private Network) protokolüdür. Geleneksel VPN çözümlerine (OpenVPN, IPSec) kıyasla daha hafif, daha az kod içeren ve yüksek performans sunan bir çözümdür.

WireGuard hizli, guvenli ve basit bir VPN protokoludur. UDP ile çalışır ve peer to peer modelinde iletisim yontemini kullanir.

## Wireguard Nasıl Çalışır?

Her istemci (peer) için bir genel (public) ve özel (private) anahtar çifti oluşturulur ve peer'lar birbirlerine baglanmak icin karsi tarafin public anahtarini kullanir.

### Handshake (El Sıkışma) Mekanizması:

WireGuard, guvenli bir anahtar degisimi(peerlarin keyleri) gerçekleştirir. Stateless çalıştığı için bağlantı durumu sürekli takip edilmez; gerektiğinde otomatik olarak yeniden bağlanır.

# WireGuard Kullanimi

WireGuard'da bir anahtar cifti olusturmak icin asagidaki komut kullanilabilir.

```
wg genkey | tee privatekey | wg pubkey > publickey
```

# Örnek Wireguard Config Dosyaları

### Client Config

```
[Interface]
Address = 10.200.200.3/32
PrivateKey = [Client's private key]
DNS = 8.8.8.8

[Peer]
PublicKey = [Server's public key]
PresharedKey = # Istege Bagli, kullanilmayacaksa satir silinmeli.
Endpoint = [Server Addr:Server Port]
AllowedIPs = 0.0.0.0/0 # VPN Uzerinden trafigin internete cikmasi icin 0.0.0.0/0 gerekmektedir. Eger sadece iki bilgisayar arasindaki baglanti saglanmak isteniyorsa sunucunun ip adresi /32 vs olabilir.
PersistentKeepalive = 21
```

### Server Config

***Not: Belirlenen subnete gore asagidaki iptables ayarlari degisiklik gosterebilir.***

```
[Interface]
Address = 10.200.200.1/24
#SaveConfig = true
PostUp =   iptables -I FORWARD 1 -i wg0 -j ACCEPT; iptables -I FORWARD 1 -o wg0 -j ACCEPT; iptables -t nat -I POSTROUTING 1 -s 10.200.200.0/24 -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT;   iptables -D FORWARD -o wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -s 10.200.200.0/24 -o eth0 -j MASQUERADE
ListenPort = 10086
PrivateKey = [Server's private key]

[Peer]
# Client 1
PublicKey = [Client's public key]
AllowedIPs = 10.200.200.2/32
PresharedKey = [Pre-shared key, same for server and client]

[Peer]
# Client 2
PublicKey = [Client's public key]
AllowedIPs = 10.200.200.2/32
PresharedKey = [Pre-shared key, same for server and client]
```