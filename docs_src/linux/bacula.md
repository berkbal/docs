# Bacula Nedir?

Bacula açık kaynak kodlu bir yedekleme ve geri yükleme yazılımıdır. Verileri otomatik olarak yedeklemek, geri yüklemek için kullanılır. Küçük ev ağlarından büyük veri merkezlerine kadar farklı ölçeklerde kullanılabilir.

## Bacula'nın Bileşenleri

Bacula belli başlı bileşenlere ayrılarak çalışır ve bu sayede kullanımı ve yönetimi kolaylaşır.

- Director (Bacula-dir): Yedekleme işlemlerini planlar ve yönetir. Bacula'nın merkezi bileşenidir.

- Storage Daemon: Yedekleme verilerini fiziksel veeya sanal depolama cihazlarına yazar.

- File Daemon (Bacula-fd): Yedeklenecek istemci makinelerde çalışarak yedeklenecek dosyaları okuyup Storage Daemon'a iletir.

- Catalog (Veritabanı): Yedekleme ve geri yükleme işlemleriyle ilgili metadata bilgilerini saklar. Genellikle MYSQL, PostgreSQL veya SQLite kullanır.

- Console: (Bconsole): Bacula'yı komut satırından yönetmek için kullanılır.

- Baculum (Web Arayüzü): Bacula'yı web tabanlı bir arayüzden kontrol etmeyi mümkün kılar.

## Bacula Adım Adım Nasıl Çalışır?

Yedekleme işleminin baştan sona nasıl çalıştığını öğrendiğimizde Bacula'yı anlamak daha kolay hale geliyor. Aşağıdaki sıra ile Bacula yedekleme işlemini gerçekleştirir:

1. Director, yapılandırılmış bir plana göre yedekleme işlemini başlatır.
2. File Daemon istemcilerdeki dosyaları okuyarak Storage Daemon'a iletir. Bu süreç gerçekleşirken Catalog yedekleme işleminin metadatasını saklar.
3. Veriler Storage Daemon tarafından belirtilen depolama cihazına yazılır.

## Sırası ile Bacula Bileşenleri Konfigürasyonu

### Bacula-dir (Director)

Bacula director'un kurulduğu sunucuda `/etc/bacula/bacula-dir.conf` dosyası ile aşağıdaki ayarlamalar yapılır: 

```
Director {                            # Director yapılandırması
  Name = bacula-dir                  # Director adı
  DIRport = 9101                     # Director için port
  QueryFile = "/etc/bacula/scripts/query.sql"  # SQL sorgu dosyası
  WorkingDirectory = "/var/lib/bacula"
  PidDirectory = "/var/run/bacula"
  Maximum Concurrent Jobs = 10      # Maksimum eş zamanlı iş
  Password = "director_password"    # Şifre (File Daemon ile eşleşmeli)
}
```

### File-Daemon (İstemcilere Kurulur)

İstemcilere file-daemon kurulduktan sonra `/etc/bacula/bacula-fd.conf` dosyasına client ayarları yazılabilir.

```
Client {
    Name = nextcloud-fd                 # İstemci adı (File Daemon'daki isimle aynı olmalı)
    Address = 192.168.1.102             # İstemci IP adresi
    FDPort = 9102                       # File Daemon portu
    Catalog = MyCatalog                 # Veritabanı
    Password = "fd_password"            # File Daemon şifresi (istemcidekiyle aynı olmalı)
    File Retention = 30 days            # Yedek dosya tutulma süresi
    Job Retention = 6 months            # İş kayıtlarının tutulma süresi
  }
```

### Storage Daemon

Storage Daemon dosyaların yedekleneceği sunucuya kurulur. Bacula Director'un bulunduğu sunucuya kurulması pratik olabilir. Ayar dosyası `/etc/bacula/bacula-sd.conf`.

```
Storage {                          # Depolama yapılandırması
  Name = File                     # Depolama cihazının adı
  SDPort = 9103                   # Storage Daemon için port
  WorkingDirectory = "/var/lib/bacula"
  PidDirectory = "/var/run/bacula"
  Maximum Concurrent Jobs = 10
}

Device {                           # Depolama cihazı bilgisi
  Name = FileStorage              # Depolama cihazı adı
  MediaType = File                # Depolama türü
  ArchiveDevice = /mnt/backup     # Yedeklerin saklanacağı dizin
  LabelMedia = yes                # Otomatik medya etiketi
  RandomAccess = Yes
  AutomaticMount = yes
  RemovableMedia = no
  AlwaysOpen = yes
}
```

### Schedule ve Job Tanımlayarak Yedekleme İşlemlerini Gerçekleştirme

Bacula-dir'in ayar dosyasına bir schedule ve job tanımlayarak yedekleme işlemlerini gerçekleştirebiliriz. Schedule, Bacula'da Run anahtar kelimesiyle tanımlanır ve farklı zamanlama türleri için birden fazla Run satırı eklenebilir. Her bir Job tanımında ilgili Schedule adı belirtilir.

Aşağıda bir Schedule ve bir Job tanımı mevcut. Buradaki ayar dosyalarını inceleyerek yapıyı anlayabilirsiniz. Job'da Schedule'ın adını veriyoruz ve Schedule tetikleniyor.

### Schedule

```
Schedule {
    Name = "WeeklyCycle"             # Zamanlama adı
    Run = Full sun at 23:05          # Her Pazar tam (full) yedekleme
    Run = Incremental mon-sat at 23:05 # Pazartesiden Cumartesiye artımlı (incremental) yedekleme
}
```

### Job

```
Job {
    Name = "Nextcloud_Backup"
    Client = nextcloud-fd
    FileSet = "Full Set"
    Schedule = "WeeklyCycle"       # Schedule ile ilişkilendirme
    Storage = File
    Pool = Default
    Messages = Standard
}
```

Config dosyalarinda bir hata olup olmadığını kontrol etmek için `sudo bacula-dir -t` komutunu kullanabilirsiniz.