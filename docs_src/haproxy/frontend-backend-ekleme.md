# Haproxy'de Frontend ve Backend Ekleyip Yonlendirme

# Frontend Ekleme


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