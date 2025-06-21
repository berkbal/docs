# Zram Nedir?

Bilgisayarın RAM'inin bir bölümünü sıkıştırıp depolama birimi gibi kullanmayı sağlayan teknoloji. Bu sayede fiziksel ramin kapasitesi artırılmış olur.

Bu oluşturulan sıkıştırılmış blok aygıtı, genellikle takas alanı (swap space) olarak kullanılır. İlk çıktığında adı "compcache" (compressed cache - sıkıştırılmış önbellek) idi ve temel amacı buydu. Ancak artık genel amaçlı bir RAM diski olarak da kullanılıyor.

Avantajlarını anlayabilmek için normal swap alanı ile zram'i karşılaştırabiliriz.

## Normal Swap Alanı Nasıl Çalışır?

Normal swap, sabit diskinizin (HDD veya SSD) bir bölümünü veya tamamını kullanan bir tür sanal bellektir. Sistemde fiziksel RAM bittiğinde, az kullanılan veriler veya programlar swap alanına taşınır. Bu sayede fiziksel RAM'de yer açılır ve sistem daha fazla uygulama çalıştırabilir.

Avantajları:

- Veri kalıcılığı: Elektrik kesilse bile takas alanındaki veriler diskinizde kalır.
- Daha büyük kapasite: Sabit diskinizdeki alan kadar büyük olabilir.

Dezavantajları:

- Yavaşlık: Sabit diskler RAM'den çok daha yavaştır. Bu yüzden swapa veri yazmak veya okumak performansta düşüşlere neden olur. Özellikle çok fazla takas kullanımı varsa sistem donmuş gibi hissedilebilir.

- Disk yıpranması: Özellikle SSD'ler için sık sık takas alanı kullanımı, diskin ömrünü kısaltabilir.

 Sysadm
Custom Gem
Zram ve Swap Karşılaştırması

Şimdi zram ile geleneksel takas alanı (swap space) arasındaki farklara ve zram'ın sunduğu avantajlara bakalım.
Geleneksel Takas Alanı (Swap Space)

Geleneksel takas alanı, sabit diskinizin (HDD veya SSD) bir bölümünü veya tamamını kullanan bir tür sanal bellektir. Sisteminizde fiziksel RAM bittiğinde, az kullanılan veriler veya programlar takas alanına taşınır. Bu sayede fiziksel RAM'de yer açılır ve sistem daha fazla uygulama çalıştırabilir.
Avantajları:

    Veri kalıcılığı: Elektrik kesilse bile takas alanındaki veriler diskinizde kalır.
    Daha büyük kapasite: Sabit diskinizdeki alan kadar büyük olabilir.

Dezavantajları:

    Yavaşlık: Sabit diskler, RAM'den çok daha yavaştır. Bu yüzden takas alanına veri yazmak veya okumak, performansta ciddi düşüşlere neden olur. Özellikle çok fazla takas kullanımı varsa sistem donmuş gibi hissedilebilir.
    Disk yıpranması: Özellikle SSD'ler için sık sık takas alanı kullanımı, diskin ömrünü kısaltabilir.

## Zram'in Avantajları ve Dezavantajları

Zram yukarıda bahsedilen gibi RAM üzerinde sıkıştırılmış bir blok aygıtıdır. Geleneksel swap alanından temel farkı verileri fiziksel diske değil RAM içinde sıkıştırarak depolamasıdır.

Avantajları:

- Hız: Zram RAM üzerinde çalıştığı için disk tabanlı swap alanından çok daha hızlı. Veri okuma ve yazma işlemleri neredeyse RAM hızında gerçekleşir. Bu sistemin hızını artırır ve takas kullanımından kaynaklanan performans düşüşlerini en aza indirir.

- Disk ömrü: Veriler diske yazılmadığı için SSD'lerin ömrünü uzatır. 
    
- Verimli RAM kullanımı: Verileri sıkıştırarak depoladığı için, mevcut RAM kapasitenizi sanal olarak artırır. Örneğin, 1GB veriyi sıkıştırarak 500MB alana sığdırabilir ve böylece RAM'de daha fazla boş yer kalmasını sağlar.

Dezavantajları:

- CPU kullanımı: Verilerin sıkıştırılması ve açılması işlemci (CPU) kullanımı gerektirir. Ancak günümüz modern işlemcileri için bu genellikle ihmal edilebilir bir yüktür.
    
- Geçici veri: Zram'daki veriler RAM'de olduğu için, elektrik kesintisi veya sistem kapanması durumunda kaybolur. Bu nedenle kalıcı depolama için uygun değildir.
    
- Sınırlı kapasite: Zram'ın boyutu, fiziksel RAM'inizin bir kısmıyla sınırlıdır. Disk tabanlı takas alanı gibi sınırsız büyüyemez.

### Zram Nasil Kurulur ve Kullanılır?

Zram en kolay şekilde zram-generator ile ayarlanır. Diğer yöntemlere Arch Wiki'den göz atılabilir. İşlemler dağıtım gözetmeksizin aynıdır. Ubuntu vs için de zram-generator paketini kurarak işlem yapılabilir.

```
sudo pacman -S zram-generator
```


`sudo vim /etc/systemd/zram-generator.conf`
[zram0]
zram-size = min(ram / 2, 4096)
compression-algorithm = zstd