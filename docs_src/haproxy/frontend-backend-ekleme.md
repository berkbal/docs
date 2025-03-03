# Haproxy'de Frontend ve Backend Ekleyip Yonlendirme

# Frontend Ekleme

Frontend ekleme islemi duruma ve config dosyasinin hangi duzende tutulmak istenmesine gore degisebilir. Ben http ve https olarak iki ayri ana frontend tanimlayip acl tanimlarini bu frontendler icerisinde yapmayi tercih ediyorum.

Asagidaki iki tanim haproxy.cfg dosyasina eklenir:

- SSL Sertifikasi bind edilen portun yanina eklenebilir. (Ayni satirda birden fazla ssl sertifikasi eklenebilir. Haproxy acl tanimlarindaki alan adlari ile sertifikalari otomatik olarak eslestirecektir.)

```
frontend http_in
    bind *:80
    mode http
    option httplog

    # ACL Tanimlari
    acl host_cloud hdr(host) -i cloud.homelab.tr
    acl host_zabbix hdr(host) -i zabbix.homelab.tr
#    redirect scheme https if !{ ssl_fc } host_cloud
#    redirect scheme https if !{ ssl_fc } host_zabbix

    #Backend Yonlendirmeleri
    use_backend cloud_backend if host_cloud
    use_backend zabbix_backend if host_zabbix

frontend https_in
    bind *:443 ssl crt /etc/haproxy/certs/yildiz-homelab.tr.pem
    mode http
    option httplog

    # ACL Tanimlari
    acl host_cloud hdr(host) -i cloud.homelab.tr
    acl host_zabbix hdr(host) -i zabbix.homelab.tr

    # Backend Yonlendirmeleri
    use_backend cloud_backend if host_cloud
    use_backend zabbix_backend if host_zabbix
```

## ACL Nedir?

HAProxy'de ACL (Access Control List), gelen istekleri belirli kriterlere göre filtreleyerek, yönlendirme veya erişim kontrolü yapmaya olanak tanıyan bir mekanizmadır. ACL'ler, belirli başlıkları (headers), kaynak IP adreslerini, istek yollarını (paths), HTTP metodlarını ve daha birçok değişkeni kontrol etmek için kullanılabilir.

## ACL Ekleme

1. Aktif olarak kullanilan frontend icerisine (443'den trafik kabul eden) asagidaki satir eklenir:

```acl host_SERVIS_ADI hdr(Host) -i ALAN-ADI```

host_SERVIS_ADI kismini siz belirleyebilirsiniz. Burada belirledigimiz isimi backend yönlendirmesinde kullanacağız. Ayrıca haproxy loglarinda gozukecegi icin loglari ayristirmak daha kolay olacaktir.

2. Aynı frontend'in içine ```use_backend``` tanimi ile belirledigimiz alan adina gelen trafikleri istedigimiz backendlere yonlendirebiliriz.

```use_backend BACKEND-ADI if BELIRLEDIGIMIZ-HOST-SERVIS-ADI```

Bu islemi yaptiktan sonra belirledigimiz alan adina gelen trafik BACKEND-ADI ile gosterdigimiz backende yonlenecek.


# Backend Ekleme

1. Backend Tanimini Yapalim:

haproxy.cfg'nin en altina:

```
backend BACKEND-ADI
   balance roundrobin
   mode http 
   server ISTEDIGIMIZ-BIR-ISIM IP-ADRESI:PORT check ssl verify none

```

4. Configi kaydedip ciktiktan sonra ```haproxy -c -f /etc/haproxy/haproxy.cfg``` komutu ile config'de hata var mi diye kontrol edilir.
5. Eger configde hata yoksa ```systemctl reload haproxy``` ile haproxy'i reloadlayabiliriz.