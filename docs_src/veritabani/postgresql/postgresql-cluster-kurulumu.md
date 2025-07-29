# PostgreSQL Cluster Kurulumu

1 Master 1 adet Slave olacak sekilde kurulum tariflenmistir.

1. Her iki sunucuda Postgresql kurulur

```
apt update
apt-get install postgresql postgresql-contrib
```

2. Her iki sunucuda postgresql.conf'a asagidaki satir eklenir.

```/etc/postgresql/16/main/postgresql.conf```

Not: buradaki "16" postgres sürümü ile alakalıdır. Kullanılan işletim sistemi sürümüne göre değişir.
```bash
shared_listen_addresses = '*'
```

3. Her iki sunucuda Firewall Ayarlamalari Yapilir.
```bash
ufw allow 5432/tcp
ufw reload
```

4. Her iki sunucuda Erişim kontrolü ayarlanır.

```/etc/postgresql/15/main/pg_hba.conf```

```bash
host    all             all             MASTER-SUNUCU-IP-ADRESI/32   md5
host    all             all             SLAVE-SUNUCU-IP-ADRESI/32   md5
host    replication     all             MASTER-SUNUCU-IP-ADRESI/32   md5
host    replication     all             SLAVE-SUNUCU-IP-ADRESI/32   md5
```

5. Master sunucuda yeni bir replikasyon kullanıcısı oluşturulur(eğer böyle bir kullanıcı varsa duruma göre bu adım atlanabilir fakat güvenlik amacıyla önerilir)

```
sudo -i -u postgres psql (sudo yoksa postgres kullanicisina geçilip psql'a bağlanılır)
CREATE USER sysadm WITH REPLICATION ENCRYPTED PASSWORD 'PAROLA-BURAYA*GELECEK';
\q
```

6. Her iki sunucuda PostgreSQL yeniden başlatılır

```bash
sudo systemctl restart postgresql
```

7. Master sunucuda replikasyon işleminin yapılandırılması gerekmektedir. Master sunucudaki postgresql.conf dosyası açılır;

```bash
/etc/postgresql/15/main/postgresql.conf
```

```
wal_level = replica # Write-Ahead Log Seviyesi. Cluster için replica veya logical seviyesi gerekir.
max_wal_senders = 5 # Aynı anda kaç adet slave sunucunun bağlanabileceği
hot_standby = on # Slave sunucuların sadece okuma amaçlı sorguları kabul edip etmeyeceğini belirler
wal_log_hints = on # Backup alırken veri bozulmalarını önlemeye yardımcı olabilir.
synchronous_commit = off #
max_replication_slots = 2 # Cluster Sayısı Kadar Ayarlanmali
```
8. Yapılan ayarlamalardan sonra postgresql yeniden başlatılır.

```
systemctl restart postgresql
```

9. Slave sunucularda kullanılmak için bir `base backup` alınması gerekmektedir.

```
sudo mkdir -p /tmp/pg_master_backup
sudo chown postgres:postgres /tmp/pg_master_backup
```

Komuttaki -X Stream parametresi WAL dosyalarinin yedekleme sirasinda surekli olarak alinmasini saglar. Slave olan sunucuya bu dosya import edildikten sonra master ile hemen senkronize olmasi icin onemlidir.

```
sudo -i -u postgres pg_basebackup -h <Master IP Adresi> -D /tmp/pg_master_backup -U sysadm -v -P -X stream
```

Daha önce oluşturulan `sysadm` kullanıcısının Parolası girildikten sonra aşağıdaki gibi bir çıktı oluşacaktır

```
root@db-1[192.168.122.50] /etc/postgresql/15/main > sudo -i -u postgres pg_basebackup -h 192.168.122.50 -D /tmp/pg_master_backup -U sysadm -v -P -X stream
Password: 
pg_basebackup: initiating base backup, waiting for checkpoint to complete
pg_basebackup: checkpoint completed
pg_basebackup: write-ahead log start point: 0/2000028 on timeline 1
pg_basebackup: starting background WAL receiver
pg_basebackup: created temporary replication slot "pg_basebackup_1864"
30596/30596 kB (100%), 1/1 tablespace                                         
pg_basebackup: write-ahead log end point: 0/2000100
pg_basebackup: waiting for background process to finish streaming ...
pg_basebackup: syncing data to disk ...
pg_basebackup: renaming backup_manifest.tmp to backup_manifest
pg_basebackup: base backup completed
```

## 10. Slave Sunucuda Postgresql Durdurulur

```
systemctl stop postgresql
```

## 11. Slave sunucudaki postgreSQL data dizini silinir.

**ÖNEMLİ BİR DATA VARSA MUTLAKA YEDEĞİ ALINMALIDIR**
```
rm -rf /var/lib/postgresql/15/main/*
```

## 12. Maste Sunucuda Alınan Yedek Slave Sunucusuna Kopyalanır

- Master'daki `/tmp/pg_master_backup` dizini slave sunucuya kopyalanir.

Master sunucudan alınan yedekler Slave sunucusunda `/var/lib/postgresql/15/main/` dizinine kopyalanir.

## 13. Slave Sunucuda İzinler Ayarlanır

```
chown -R postgres:postgres /var/lib/postgresql/15/main
chmod -R 0700 /var/lib/postgresql/15/main
```

## 14. Slave Sunucusundaki Cluster Ayarlari Yapilir.

```
vim /etc/postgresql/15/main/postgresql.conf
```

```
hot_standby = on # Mutlaka ON olmali. Read sorgulari kabul ederken ayni zamanda verileri replike etmesini saglar.
primary_conninfo = 'host=MASTER-DB-IP port=5432 user=sysadm password=parola_buraya_gelecek'
primary_slot_name = 'db2'
```

## 15. Slave Sunucuda Standby Signal Dosyasının Oluşturulması

PostgreSQL 12 ve sonraki sürümlerde, bir sunucunun standby (kopya) olarak başlatılacağını belirtmek için boş bir standby.signal dosyası kullanılır. Main dizininin içerisinde olur.
```
touch /var/lib/postgresql/15/main/standby.signal
chown postgres:postgres /var/lib/postgresql/15/main/standby.signal
```

## 16. Master Sunucuda db2 replikasyonunun olusturulmasi

```
psql -U postgres

SELECT pg_create_physical_replication_slot('db2');
\q
```
## 17. Slave Sunucuda PostgreSQL Tekrar Başlatılır

```
systemctl start postgresql
```

Sorunsuz bir sekilde cluster yapisi kurulmus durumdadir.