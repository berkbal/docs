# Certbot Nedir?

Certbot, HTTPS bağlantılar için otomatik bir şekilde Let's Encrypt sertifikaları oluşturmayı ve yönetmeyi sağlayan ücretsiz, açık kaynaklı yazılım aracıdır.

## Certbot ile DNS-01 Challenge Kullanarak Wildcard Sertifika Alma

1. Certbot kurulu değilse aşağıdaki komut ile certbot kurulur

```
sudo apt update
sudo apt install certbot
```

2. Asagidaki komuttaki alan adi kismi degistirilerek wildcard sertifika isteginde bulunulur:

```
certbot certonly --manual --preferred-challenges dns -d "*.alan-adiniz.com"

```

3. Certbot size mail adresi soracak, kullanmakta oldugunuz bir mail adresini verebilirsiniz. Certbot sertifikanız bitmeye yaklaştığında size mail gönderiyor.(4 Haziran 2025'den itibaren artık yapmıyor)

4. Gelen ikinci seçeneğe Yes diyerek cevap verebilirsiniz.

5. Bir adet TXT kaydi olusturmaniz gerekecek. Konsoldaki isim ile bir TXT kaydi olusturun.

6. Ayni islemi bir kere daha yapmaniz gerekecek, girmis oldugunuz dns kaydini yeni VALUE ile duzenleyip tekrar enter'a basabilirsiniz.

7. Sertifikaniz certbot'un belirledigi dizinde olusmus olacak. Konsol ciktisindan dizini gorebilirsiniz.