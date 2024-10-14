# Swaks (Swiss Army Knife for SMTP)

## Swaks Nedir?

Swaks (Swiss Army Knife for SMTP), Linux sistemlerde e-posta sunucularını test etmek ve SMTP protokolü üzerinden e-posta gönderme işlemlerini incelemek için kullanılan bir komut satırı aracıdır. Oldukça esnek ve kullanımı kolaydır, bu sayede SMTP, SMTPS (TLS ve STARTTLS), ve diğer protokollerle ilgili sorunları tespit etmek için yaygın olarak kullanılır.

### Kurulum

```
sudo apt install swaks
```

### Swaks Kullanımı

En basit hali ile bir test maili göndermek için:

```
swaks --to recipient@example.com
```

Belirli bir SMTP sunucusuna bağlanarak mail göndermek için:

```
swaks --to recipient@example.com --server smtp.example.com
```

TLS ile bir sunucuya bağlanmak için

```
swaks --to recipient@example.com --server smtp.example.com --tls
```

Kimlik doğrulaması yaparak bir sunucuya bağlanmak için

```
swaks --to recipient@example.com --server smtp.example.com --auth LOGIN --auth-user username --auth-password password
```

Bir mail 2 adet parçadan oluşur.(Header ve Body) Bu kısımları özelleştirerek bir mail göndermek için swaks komutu aşağıdaki gibi kullanılır:

```
swaks --to recipient@example.com --from sender@example.com --header "Subject: Test Email" --body "This is a test email."
```
Genel anlamda swaks'ın nasıl kullanıldığını anladıktan sonra parametrelere ve özelliklerini inceleyebiliriz.


### Swaks Parametreleri

1. ```--to [email_address]:```

Gönderilecek e-postanın alıcı adresini belirtir.

Örnek: ```--to mail@testsunucusu.com.tr```

2. ```--from [email_address]:```

Gönderici e-posta adresini belirtir. Varsayılan olarak sistemin hostname’i kullanılır.

Örnek: ```--from relay-test@testsunucusu.com.tr```

3. ```--server [hostname]:```

SMTP sunucusunun adresini belirtir. Sunucuya bağlanmak için kullanılan IP adresi veya hostname olabilir.

Örnek: ```--server docker.testsunucusu.com.tr```

4. ```--port [port_number]:```

SMTP sunucusuna bağlanmak için kullanılan port numarasını belirtir. Varsayılan olarak 25’tir, ancak SMTPS için genelde 465, STARTTLS için 587 gibi portlar kullanılır.

Örnek: ```--port 2527```

5. ```--helo [domain_name]:```

SMTP sunucusuna gönderilen HELO veya EHLO komutunda kullanılan domain adını belirtir. SMTP sunucusuna kendinizi tanıtmak için kullanılır.

Örnek: ```--helo mail.berkbal.tr```

6. ```--auth [auth_type]:```

SMTP kimlik doğrulaması için kullanılan yöntemdir. Desteklenen yöntemler arasında PLAIN, LOGIN, CRAM-MD5 gibi seçenekler vardır.

Örnek: ```--auth LOGIN```

7. ```--auth-user [username]:```

SMTP kimlik doğrulaması için kullanılan kullanıcı adını belirtir. --auth parametresi ile birlikte kullanılır.

Örnek: ```--auth-user username```

8. ```--auth-password [password]:```

SMTP kimlik doğrulaması için kullanılan şifreyi belirtir. --auth ve --auth-user ile birlikte kullanılır.

Örnek: ```--auth-password password```

9. ```--tls:```

SMTP sunucusuna TLS (SMTPS) üzerinden bağlanmak için kullanılır. SMTPS genellikle 465 numaralı portta çalışır.

Örnek: ```--tls```

10. ```--tls-starttls:```

Bağlantı kurulduktan sonra STARTTLS komutu kullanarak bağlantıyı şifrelemek için kullanılır. STARTTLS genellikle 587 numaralı portta çalışır.

Örnek: ```--tls-starttls```

11. ```--header [header]:```

E-posta başlıklarını manuel olarak ayarlamak için kullanılır. Bu başlıklar e-posta mesajına eklenir.

Örnek: ```--header "Subject: Test Email"```

12. ```--body [message]:```

Gönderilecek e-posta mesajının içeriğini belirtir.

Örnek: ```--body "This is a test message"```

13. ```--quit-after [smtp_command]:```

Belirtilen SMTP komutundan sonra sunucuya QUIT komutunu gönderip bağlantıyı kapatır. SMTP oturumunu tamamlama zorunluluğu olmayan testler için kullanılır.

Örnek: ```--quit-after DATA```

14. ```--timeout [seconds]:```

Sunucuya bağlantı kurarken kullanılacak zaman aşımı süresini belirtir.

Örnek: ```--timeout 10```

15. ```--suppress-data:```

E-posta içeriğiyle ilgili çıktıyı bastırır. Sunucuyla ilgili geri bildirim görmek istiyorsanız ancak içerik kısmını görmek istemiyorsanız kullanılır.

Örnek: ```--suppress-data```

16. ```--add-header [header]:```

E-postaya ek bir başlık (header) eklemek için kullanılır.
Örnek: --add-header "X-Custom-Header: CustomValue"

17. ```--dump:```

SMTP sunucusuna gönderilen ve sunucudan alınan her bir komutu ve cevabı ekranınıza yazdırır. Debug amaçlı kullanılır.

Örnek: ```--dump```

18. ```--force-getpwuid:```

Kendi kullanıcı adınızı otomatik olarak belirlemek için getpwuid() fonksiyonunu zorlar. Bu genellikle default davranıştır, ancak bazı sistemlerde elle belirtilmesi gerekebilir.

19. ```--verbose:```

Komutun daha ayrıntılı bilgi döndürmesini sağlar. SMTP sunucusuyla olan iletişimin daha detaylı bir çıktısını verir.

Örnek: ```--verbose```

20. ```--debug:```

Komutun debug modunda çalışmasını sağlar ve detaylı hata çıktıları verir.

Örnek: ```--debug```

21. ```--attach```

Örnek: ```--attach /path/to/your/file.txt```


### Testler İçin Örnek Komut: 

```
swaks --to mail@x.com --from relay-test@berkbal.com.tr --server mail.testsunucusu.com --port 2527 --helo mail.berkbal.com.tr
```

