***Wireguard server kurulumunu ayri bir yerde paylasacagim. Bu dokuman sadece nasil kullanilacagini icermektedir.***

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

