# TcpDump Nedir?

tcpdump, ağ trafiğini analiz etmek için kullanılan bir komut satırı aracıdır. Network kartı üzerinden geçen TCP/IP paketlerini yakalar ve detaylı bilgi sunar. Ağ trafiğinin analiz edilmesi, sorunların tespiti veya güvenlik denetimleri gibi durumlarda sıklıkla kullanılır. Ayrıca, yalnızca TCP paketleri değil, UDP, ICMP gibi diğer protokol paketlerini de izleyebilir.

## TcpDump Nasıl Kullanılır?

tcpdump komutuna verilebilecek en gerekli 3 option su sekilde:

1. -i [interface-adi] hangi interface'e gelen paketlerin dinlenecegini bu sekilde secebiliriz. Eger -i ile belirtmezsek cok fazla paket gozukecegi icin aradigimiz paketleri bulamayabiliriz. Bu sekilde gormek istedigimiz paketleri bu sekilde gorebiliriz.
2. -src [IP] Gelen paketin 'source' kısmında hangi ip adresinin yazması gerektiğini belirtebiliriz. Sadece belirli bir makineden gelen paketleri izlemek istiyorsak oldukca faydali. 
3. -dst [IP] Gelen paketin 'destination' kisminda hangi ip adresinin yazmasi gerektigini belirtebiliriz. Sadece belirli bir ip adresine route edilen veya giden paketleri izlemek icin kullanilabilir. NAT islemlerinde oldukca kullanisli.

### Örnek Komut

Asagidaki komut eno1 interface'inden gecen source ip adresi 192.168.1.170 olup destination'u 192.168.1.180 olan paketleri listeleyecektir.

```
tcpdump -i eno1 src 192.168.1.170 dst 192.168.1.180
```