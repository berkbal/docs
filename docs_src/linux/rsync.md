# Rsync Nedir?

```
man rsync
rsync - a fast, versatile, remote (and local) file-copying tool
```

rsync (Remote Sync), dosya ve dizinleri yerel veya uzak sistemler arasında senkronize etmek için kullanılan hızlı ve verimli bir araçtır. Diferansiyel (artımlı) senkronizasyon yaparak yalnızca değişen dosyaları kopyalar, bu da onu hızlı ve bant genişliği dostu bir çözüm haline getirir.

## Rsync Nasıl Kullanılır?

1. Temel Kopyalama
```
rsync -av kaynak_dizin hedef_dizin
```

2. Uzak Sunucuya Dosya Gönderme
```
rsync -av dosya user@remote_host:/hedef_dizin/
```

### SSH Uzerinden Dosya Gondermek Icin

```
rsync -av -e ssh dosya user@remote_host:/hedef_dizin/
```

3. Uzak Sunucudan Dosya Alma

```
rsync -av user@192.168.1.10:/backup/proje/ /home/user/proje/
```

Bu komut, uzak sunucudan /backup/proje/ dizinini yerel /home/user/proje/ dizinine indirir.