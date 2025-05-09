# Roundcube

Roundcube kullanicilarin mail okuyup gonderebildigi ve posta kutularina filtreler ekleyebildigi bir webmail uygulamasidir. Buradaki docker compose dosyasi lokal mail istemcisi amaciyla kullanmak icin olusturulmustur. Eger hostlanip baska insanlar ile paylasilacaksa degistirilmesi ve duruma gore ayarlanmasi gerekmektedir.

## docker-compose.yml

```
version: '2'

services:
  roundcubemail:
    image: roundcube/roundcubemail:latest
    container_name: roundcubemail
#    restart: unless-stopped
    volumes:
      - ./www:/var/www/html
      - ./db/sqlite:/var/roundcube/db
    ports:
      - 127.0.0.1:9002:80 # Sadece localhost tarafindan erisilmesi icin portun bu sekilde ayarlanmasi gerekiyor. Normalde docker iptables ve ufw ile tanimlanan kurallari ezecektir.
    environment:
      - ROUNDCUBEMAIL_DB_TYPE=sqlite
      - ROUNDCUBEMAIL_SKIN=elastic # Tema?
      - ROUNDCUBEMAIL_DEFAULT_HOST=tls://mail.domain.com.tr # Posta Kutusu
      - ROUNDCUBEMAIL_SMTP_SERVER=tls://smtp.domain.com.tr # SMTP Sunucusu
```