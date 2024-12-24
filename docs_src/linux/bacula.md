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