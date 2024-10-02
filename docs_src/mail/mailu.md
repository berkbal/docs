# Mailu Nedir?

![Mailu-Logo](mailu/mailu.png)

Mailu, güvenli, özelleştirilebilir ve açık kaynaklı bir e-posta sunucu çözümüdür. Modern teknolojilerle geliştirilen Mailu, bireyler ve işletmeler için bağımsız e-posta sunucusu işletimini kolaylaştırır. Docker konteynerlerinde çalışarak kolay kurulum ve bakım imkanı sağlar. Mailu, kullanıcı dostu bir arayüzle e-posta yönetimini basitleştirir, spam ve virüs koruması gibi gelişmiş güvenlik özellikleri sunar. IMAP, SMTP ve Webmail gibi yaygın e-posta protokollerini destekler. Ayrıca, yüksek ölçeklenebilirliği sayesinde küçük işletmelerden büyük organizasyonlara kadar geniş bir kullanıcı yelpazesi için idealdir. Mailu, açık kaynak topluluğundan gelen katkılarla sürekli gelişir ve güncellenir, bu da onu esnek ve güvenilir bir e-posta çözümü haline getirir.

Docker Compose dosyasını generate etmek için [bu adresi](https://setup.mailu.io/) kullanabilirsiniz.

## Mailu Kurulumu

Mailu en güncel Docker ve Docker Compose teknolojilerini kullandığı için bu kurulumların Docker’ın resmi repolarından yapılması gerekmektedir. Muhtemelen kullandığınız Linux dağıtımının repolarında bulunan Docker Engine ve Docker Compose Mailu için uygun olmayacaktır. Mailu’nun sistem gereksinimleri ve kullanılacak Docker ve Docker Compose versiyonları hakkında bilgi almak için [resmi sitesini](https://mailu.io/2024.06/compose/requirements.html) ziyaret edebilirsiniz.

![Docker Logo](./mailu/docker-logo-blue-300x68.png)

1. Mailu Storage Path: Mailu’nun verilerini depolayacağı dizini belirtir. Mailu'nun docker volume dosyalarının, gerekli env dosyasının ve docker compose dosyasının bulunacağı dizini buraya girin. Örneğin `/mailu.`

2. Main Mail Domain and Server Display Name: Ana mail domaini ve sunucu adı bu alana girilmelidir. Örneğin, `berkbal.com.tr.`

3. Postmaster Local Part: Postmaster e-posta adresinin yerel kısmını belirtir. Genellikle admin olarak kullanılır.

4. TLS Sertifikaları: TLS sertifikalarını nasıl yönetmek istediğinizi seçin. letsencrypt gibi bir seçenek belirleyebilirsiniz.

5. Giriş Denemesi Limitleri: Belirli bir IP adresinden yapılan başarısız giriş denemeleri için saatlik limit. Örneğin, 5/saat.
Kullanıcı başına günlük giriş deneme limiti. Örneğin, `50/gün.`

6. Gönderim Limitleri: Kullanıcı başına günlük gönderilebilecek mesaj limiti. Örneğin, `200/gün.`

7. Anonim İstatistikler: Anonimleştirilmiş istatistiklere katılmak isteyip istemediğinizi belirleyin.

8. Website Name: Web sitesinin adını girin. Örneğin, `Berk Bal.`

9. Linked Website URL: Bağlantılı web sitesinin URL’sini girin. Örneğin, `https://berkbal.com.tr`

10. Yönetim Arayüzü: Yönetim arayüzünü etkinleştirin. Bu seçenek, Mailu’nun yönetim araçlarına erişim sağlar.

11. API: API’yi etkinleştirin. Mailu’nun yapılandırmasını değiştirmek için RESTful API’yi kullanabilirsiniz. API’yi etkinleştirdiğinizde size bir TOKEN üretip verecektir.

### Ekstra Tercihler

Mailu, bir yönetici arayüzü, web e-posta istemcileri, antispam, antivirüs gibi birden fazla temel özellik ile birlikte gelir. Bu bölümde, tercihlerinize göre servisleri etkinleştirebilirsiniz:

1. **Web E-posta İstemcisi:** Bu seçenek, kullanıcıların web üzerinden posta kutularına erişmelerini sağlar. `Roundcube`, veya `rainloop` seçeneklerinden birini seçebilirsiniz.

2. **Antivirüs Hizmeti:** **ClamAV** kullanarak büyük ölçekli virüs yayılma kampanyalarına karşı koruma sağlar. Bu hizmeti etkinleştirmek için **en az 1GB bellek gereklidir.**

3. **Webdav Hizmeti:** Kullanıcıların HTTP üzerinden takvim ve rehber gibi bilgileri depolamalarını sağlar.

4. **Fetchmail:** Kullanıcıların harici bir mail sunucusundan ``IMAP/POP3`` ile posta çekip gelen kutularına yerleştirmelerini sağlar.

5. **Oletools:** E-posta eklerindeki belgeleri kötü amaçlı makrolara karşı tarar. Tam teşekküllü bir antivirüs programına göre daha düşük bellek kullanır.

6. **Tika:** Tika’yı etkinleştirir. E-posta ekleri içinde arama yapma işlevini sağlar. Tika, e-posta eklerindeki belgeleri tarar, işler (OCR, anahtar kelime çıkarımı) ve verimli bir şekilde aranabilir hale getirir. Bu işlem önemli miktarda kaynak (RAM, CPU ve depolama) gerektirir.

## Sunucu Ayarları

Mail sunucusunun e-posta alabilmesi, gönderebilmesi ve kullanıcıların posta kutularına erişebilmesi için dünyaya açılması gerekmektedir. Mailu, bu işlemi çeşitli yollarla yapabilir:

1. **IPv4 Listen Address:** IPv4 listen address alanına satın aldığınız sunucunun IP adresini yazmalısınız. Örneğin, 192.168.1.50.

2. **Subnet of the Docker Network:** Docker ağının alt ağını belirtin. Bu ağ, sisteminizin bağlı olduğu herhangi bir ağ ile çakışmamalıdır. Genellikle format *.*.*.0/24 şeklindedir. Örneğin, 192.168.203.0/24.

3. **IPv6:** Bu, Mailu’nun DNSSEC doğrulamasını yapmasına, DNS kök sorgularını ve önbelleklemesini gerçekleştirmesine olanak tanır.

4. **Internal DNS Resolver (Unbound):** Bu seçenek, antispam hizmetinin genel veya ISS DNS sunucuları tarafından engellenmemesine yardımcı olur.

5. **Public Hostnames:** Sunucunun barındıracağı genel ana bilgisayar adlarını girin. Bu alan adları, e-posta alan adlarının MX kayıtlarında belirtilmelidir. Ana bilgisayar adları virgülle ayrılmalıdır. Örneğin: mail.berkbal.com.tr.

Bu adımları tamamladıktan sonra, ``docker-compose.yml`` ve ``mailu.env`` dosyalarını oluşturup wget ile sisteme indirip kullanabileceksiniz.