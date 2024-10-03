# Log Rotasyonu Nedir?

Log rotasyonu güncel/yeni log dosyalarını etkilemeden eski log dosyalarını silme/yedekleme işlemidir. Kullanıldığı alana göre her uygulama önemli loglar üretir ve bu logları genelde kaybetmek istemeyiz. Eğer bu logları silmezsek kullandığımız sunucunun disk kapasitesi kısa bir süre sonra dolabilir.

Logları silmek yerine bizim için otomatik olarak gzip formatında arşivleyen Logrotate adında bir yazılım var.

Logrotate, log dosyalarını yönetmeye, sıkıştırmaya, kaldırmaya ve hatta belirli bir zaman aralığından sonra (örneğin günlük, haftalık, aylık vb.) e-postayla bir yere göndermeye yardımcı olur.

## Kurulum

Çoğu Linux dağıtımı varsayılan olarak Logrotate ile gelir. Eğer sisteminizde mevcut değilse, aşağıdaki komutlarla kolayca kurulabilir:

### RHEL/CentOS

```yum install logrotate```

### Debian/Ubuntu

```apt-get install logrotate```

### Fedora

```dnf install logrotate```

## Nasıl çalışır?

Logrotate, işlem yapmak istediğiniz tüm log dosyalarını belirtebileceğiniz bir yapılandırma dosyasına sahiptir. Günlük, haftalık, aylık vb. gibi bir zaman periyodu birimine ve her döndürme için 3, 4, 5 gibi döndürme sayısına ihtiyacı vardır. Log dosyaları kaldırılmadan önce döndürme sayısı kadar döndürülür. Varsayılan döndürme sayısı 0'dır, bu da eski günlük sürümlerinin döndürülmek yerine kaldırılacağı anlamına gelir. Yani günlükleriniz **my-application.log** adlı bir dosyaya kaydediliyorsa, bir döndürmeden sonra my-application.1.log adlı yeni bir dosya oluşturulur.

### Ayar Dosyası

Logrotate yapılandırma dosyası ```/etc/logrotate.conf```'da bulunur. Örnek bir yapılandırma dosyası şuna benzer bloklar içerir:

```
/var/lib/docker/containers/*/*.log {
    rotate 5
    copytruncate
    missingok
    notifempty
    compress
    maxsize 200M
    daily
}
```
Şimdi bu log dosyasını adım adım inceleyelim:

```/var/lib/docker/containers/*/*.log```

Logrotate'in hangi dosyayı veya dosyalara işlem uygulayacağını gösteren yoldur.  `{ }` içerisindeki kuralları ```/var/lib/docker/containers``` dizinindeki bütün dizinlerin içerisindeki ```.log``` ile biten dosyalara aşağıdaki kuralları uygulayacak:

```rotate 5```

Loglari en fazla 5 kere saklar, yani işlem yapıldığında en fazla 5 dosya eski günlük saklanacak ve halihazırda 5 dosya olduğunda en eski günlükler silinecek.

Örnek: 

```
my-application.log 
my-application.log1 
my-application.log2 
my-application.log3 
my-application.log4 
my-application.log5
```

```copytruncate```

Eski log dosyalarını taşıyıp isteğe bağlı olarak yenisini oluşturmak yerine, bir kopya oluşturduktan sonra orijinal log dosyasını bulunduğu yerde, 0 KB boyutuna küçültür. ***Bazı uygulamaların*** log dosyasını kapatması mümkün olmadığında ve önceki log dosyasına yazmaya devam edebileceği durumlarda kullanılabilir. Dosyanın kopyalanması ve küçültülmesi arasında çok küçük bir zaman dilimi olduğu için log kaybı olabilir.

```missingok```

Eğer log dosyası eksikse, bir hata oluşturmaz ve bir sonraki dosyaya geçer.

```notifempty```

Log dosyasının içeriği boşsa log rotate işlemi gerçekleştirmez.

```compress```

Eski log dosyalarını gzip formatında sıkıştırır.

```maxsize 200M```

Log dosyası, rotate kuralından bağımsız olarak 200 MB boyutunu aşarsa rotate işlemini gerçekleştirir. Bu ayar ileride ***zgrep*** kullanılarak sıkıştırılmış dosyaların içerisinde bir log ararken dosyanın boyutunun fazla büyük olmaması sağlanırsa avantaj sağlar.

```daily```

Log rotate işlemini günlük olarak gerçekleştirir.