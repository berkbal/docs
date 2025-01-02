# SFTP Nedir?

SFTP, SSH üzerinden güvenli olarak dosya aktarımı yapan protokoldür.  SFTP sadece dosya aktarmakla kalmaz, dizin listeleme, dizin oluşturma, dizin ve dosya silme, dizinleri yeniden isimlendirme gibi özellikleri de bünyesinde barındırır.

## SFTP Bağlantısı Nasıl Kurulur?

İşletim sistemi farketmeksizin `sftp kullanici-adi@sunucu-adresi` şeklinde bağlantı sağlanabilir.

## SFTP Komutları

### Dizin Komutları

1. pwd: SFTP ile bağlanılan sunucuda bulunulan dizini ekrana yazdırır.
2. lpwd: kendi makinenizde bulunduğunuz dizini ekrana yazdırır.
3. lcd: Kendi makinenizde bulunulan dizini değiştirir.
4. lls: Kendi makinenizde bulunduğunuz dizindeki dosyaları listeler.

### Dosya Transferleri

1. put: Dosya yükler.
2. get: Dosya indirir.