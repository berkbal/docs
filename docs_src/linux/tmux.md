# Tmux Nedir?

Tmux, Screen'in modern bir alternatifidir. Birden fazla terminal oturumunu aynı anda yönetmenizi sağlar. .tmux.conf dosyası ile özelleştirilenbilir. Daha moderndir. Adamdır.

## Nasil Kurulur?

```
apt-get install tmux
```

### Tmux Kısayolları

1. Ctrl+b **c** ile yeni bir pencere açar.
2. Ctrl+b **,** ile bulunan pencereye isim verir(kullanıcıdan isim için input alır)
3. Ctrl+b **ID** ile oluşturulan pencereler arasında geçiş yapılır. Pencerelerin isimleri ve idleri terminalin altında yazar.


## Ekran Bölme

1. Ctrl + b ve " ile ekranı yatay olarak böler.
2. Ctrl + b ve % ile ekranı dikey olarak böler.

### Bölmeler Arasında Gezinme

- Ctrl + b ve ok tuşları ile bölmeler değiştirilebilir.

### Önerilen Tmux Ayarları

1. ```set -g mouse on``` Tmux üzerinde fare kullanımını mümkün kılar.