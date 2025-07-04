# Fail2ban Nedir ve Nasıl Çalışır?

Fail2ban Linux sunucularda log dosyalarını izleyen bir güvenlik yazılımıdır. Bu log dosyalarında belirli patternları arar. Örneğin, bir kullanıcının yanlış parola girmesi gibi başarısız giriş denemeleri veya belirli bir porta yapılan aşırı istekler bu desenlere örnek olabilir.

Belirlenen eşik değerlerine (thresholds) ulaşıldığında, Fail2ban bu saldırgan IP adresini güvenlik duvarına (firewall) bildirir ve o IP adresinin belirli bir süre veya kalıcı olarak engellenmesini sağlar.

---

## Fail2Ban Kurulumu


```bash
apt update
apt install fail2ban
```

```bash
systemctl start fail2ban
systemctl enable fail2ban
```

## Fail2ban Yapılandırma Dosyaları

### /etc/fail2ban/jail.conf

Bu dosya Fail2ban'ın ana yapılandırma dosyasıdır ve varsayılan ayarları içerir. Genelde bu dosyayı doğrudan değiştirmemek önerilir. Fail2ban güncellemeleri sırasında bu dosya üzerine yazılabilir ve yaptığınız değişiklikler kaybolabilir.

### /etc/fail2ban/jail.local

Bu dosya jail.conf dosyasındaki ayarları geçersiz kılmak (override etmek) veya yeni ayarlar eklemek için kullanılır. Bu dosyayı elle oluştururuz ve tüm özel yapılandırmalarımızı buraya yazarız. Bu sayede güncellemelerden etkilenmeyiz.

---
## Jail.local Dosyası Oluşturmak

Aşağıdaki komut ile dosya oluşturulur.

```bash
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
```

---

### Nginx için Fail2ban Yapılandırması

Belirli bir ip adresinden 30 saniyede 100 istekten fazla geliyorsa 5 dakika boyunca 443 ve 80 numaralı portlara erişememesini sağlamak için aşağıdaki işlemler uygulanır.

```bash
vim /etc/fail2ban/filter.d/nginx-request-bot.conf
```

Dosyanın içeriği aşağıdaki gibi düzenlenir.
```bash
[INCLUDES]
before = common.conf
# failregex Nginx'in erişim loglarındaki her satırı yakalar.
# <HOST> Fail2ban'ın IP adresini yakalamak için kullandığı özel bir etikettir.
[Definition]
failregex = ^<HOST> -.*"(GET|POST|HEAD|PUT|DELETE|OPTIONS).*"\s+(?:HTTP/1\.[01])?"\s+\d+\s+\d+\s+".*?"\s+".*?"$

ignoreregex =

```

Özel filtreyi oluşturduktan sonra oluşturduğumuz `jail.local` dosyasını düzenleyerek bu filtreyi uygulayabiliriz.

---

jail.local dosyası açılır ve dosyanın en alt satırına aşağıdaki içerik eklenir

```bash 
[nginx-request-bot]
enabled = true
# Kullandığımız özel filtre dosyasının adını belirtiyoruz.
filter = nginx-request-bot
# Nginx access log dosyasının pathi.
logpath = /var/log/nginx/access.log
# Yasaklama süresi: 5 dakika (300 saniye).
bantime = 300
# Fail2ban'in istekleri saymak için geriye dönük bakacağı süre: 30 saniye.
findtime = 30
# 30 saniye içinde 100'den fazla istek gelirse yasakla.
maxretry = 100
# Sadece 80 ve 443 portlarına gelen istekler için geçerli olmasını istiyorsanız:
port = http,https
# Veya port numaralari da belirtilebilir.
# port = 80,443
```

Bu ayarlar yapıldıktan sonra fail2ban restartlanır.

```bash
systemctl reload fail2ban
```

## Oluşturulan Hapishanelerin Görüntülenmesi

Aşağıdaki komutla oluşturulan hapishaneler görüntülenebilir.

```bash
root@sunwell:/etc/fail2ban/filter.d# fail2ban-client status                  
Status
|- Number of jail:	2
`- Jail list:	nginx-request-bot, sshd
```

İstediğimiz jail hakkında bilgi almak için komutun sonuna jailin adını ekleyebiliriz.

```bash
root@sunwell:/etc/fail2ban/filter.d# fail2ban-client status nginx-request-bot
Status for the jail: nginx-request-bot
|- Filter
|  |- Currently failed:	0
|  |- Total failed:	0
|  `- File list:	/var/log/nginx/access.log
`- Actions
   |- Currently banned:	0
   |- Total banned:	0
   `- Banned IP list:	
```

