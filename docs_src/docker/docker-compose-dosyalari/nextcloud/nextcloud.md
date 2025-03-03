# Nextcloud

Bu docker compose dosyasi nextcloud'i ve mariadb'yi docker-compose ile ayaga kaldiracaktir. Nextcloud'in datasi baska bir dizine(Baska bir fiziksel disk) mount edilili durumda.

```
version: '3.9'

services:
  db:
    image: mariadb:11.4
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: MYSQL'DEKI ROOT KULLANICISININ PAROLASI
      MYSQL_DATABASE: nextcloud
      MYSQL_USER: homelab
      MYSQL_PASSWORD: PAROLA
    volumes:
      - homelab_db_data:/var/lib/mysql

  nextcloud:
    image: nextcloud:30.0.6
    ports:
      - 8081:80
    restart: always
    volumes:
      - homelab_nextcloud_data:/var/www/html
    environment:
      MYSQL_DATABASE: nextcloud
      MYSQL_USER: homelab
      MYSQL_PASSWORD: PAROLA(homelab kullanicisinin parolasi)
      MYSQL_HOST: db
      SERVER_NAME: DOMAIN
      PHP_OPCACHE_MEMORY_CONSUMPTION: 256
      TRUSTED_PROXIES: '192.168.1.10' # Reverse proxy durumunda Trusted Proxies degiskenine hangi ip'den gelindigi yazilmalidir.
    depends_on:
      - db

volumes:
  homelab_db_data:
  homelab_nextcloud_data:
    driver_opts:
      type: none
      o: bind
      device: /mnt/cloud-data
```