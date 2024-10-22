# SS Komutu

```ss``` komutu ile linux sunucumuzun nerelerden bağlantı aldığını öğrenebiliriz. Açık portlar ve soketler ```ss``` komutu ile kontrol edilebilir. Hangi portların dinlenildiği de ss ile kontrol edilebilir.

***soket, iki program arasında veri alışverişini sağlayan bir haberleşme mekanizmasıdır. Soketler, bir ağ bağlantısı ya da aynı sistemde çalışan iki uygulama arasında veri aktarımı için kullanılabilir. Genellikle bir istemci ve bir sunucu uygulaması arasında veri alışverişi sağlamak amacıyla kullanılır.***

## SS Komutu Nasıl Kullanılır?

```
ss
```

Bu komutun çıktısı sistemdeki bütün bağlantıları gösterir.

## TCP Bağlantılarını Görme

```
ss -t
```
Bu komut ile sadece TCP bağlantıları izlenebilir.

## Listening TCP Bağlantılraını Görme

```
ss -tl
```
Bu komut ile sadece TCP ve sunucunun dinlediği bağlantılar görüntülenebilir.

## Sadece ipv4 Bağlantılarını Görme

```
ss -4
```
