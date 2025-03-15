# Truncate nedir?

Linux'ta 'truncate' komutu, bir dosyanın boyutunu değiştirmek için kullanılır. En önemli özelliği, dosyayı silmeden içeriğini boşaltabilmesidir. Yani dosya yerinde kalır ama içi boşalır.

Bu özellikle log dosyaları veya çalışan uygulamaların kullandığı dosyalarla uğraşırken hayat kurtarıcı olabilir. Dosyayı silsem, uygulama hata verebilir. Ama boşaltırsam, hem yer açarım hem de yapı bozulmaz.

## Temel kullanımı

Temel kullanımı oldukça basit:

```bash
truncate -s BOYUT DOSYA_ADI
```

Burada `-s` parametresi "size" yani boyut anlamına gelir. Boyut için çeşitli birimler kullanılabilir.

## Pratik örnekler

En yaygın kullanım, bir dosyayı tamamen boşaltmaktır:

```bash
truncate -s 0 buyuk_log_dosyasi.log
```

Bu komut, dosyanın içeriğini sıfırlar ama dosya hala vardır. Uygulama çalışmaya devam eder ve yeni loglar bu dosyaya yazılır.

Belirli bir boyuta da ayarlayabilirsiniz:

```bash
truncate -s 1M veritabani.dat
```

Bu, dosyayı 1 megabayta keser.

Mevcut boyuta göre ayarlama da yapabilirsiniz:

```bash
truncate -s +500K dosya.txt    # 500 KB ekle
truncate -s -2M dosya.txt      # 2 MB çıkar
```

## Ne zaman kullanmalı?

Şu durumlarda truncate kullanmak mantıklıdır:

- Log dosyaları biriktiğinde
- Docker konteynerlerinde silme yetkisi olmadığında
- Çalışan bir sistemi bozmadan yer açmak gerektiğinde
- Dosya yapısını korumak ama içeriği temizlemek istediğinizde

Geçen haftaki sorunumda, konteyner içindeki 8GB'lık log dosyasını `truncate -s 0` ile anında temizledim ve sistem çalışmaya devam etti.

Bu basit ama güçlü komut, sistem yöneticisinin alet çantasında bulunması gereken araçlardan biridir.