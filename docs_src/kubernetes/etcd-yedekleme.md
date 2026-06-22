# etcd Yedekleme

Kubernetes clusterinin butun state'i `etcd` uzerinde tutulur. Podlar, Secretlar, ConfigMapler, Deploymentlar, RBAC kurallari kisacasi clusterin hafizasi hep buradadir. API server stateless calisir, asil veri etcd'dedir.

Bu yuzden etcd'yi kaybetmek clusterin hafizasini kaybetmek demektir. Nodelar ayakta olsa bile Kubernetes ne yapacagini bilemez. Yedek aldigimiz sey etcd'nin o anki goruntusudur (snapshot), tek bir `.db` dosyasi olarak diske yazilir.

## etcdctl Hazirligi

Snapshot islemi `etcdctl`'in v3 API'si ile calisir. Yeni surumlerde v3 zaten varsayilandir ama garanti olsun diye komutlarin basina `ETCDCTL_API=3` koymak iyi bir aliskanliktir.

```bash
ETCDCTL_API=3 etcdctl version
```

Kurulu degilse:

```bash
apt-get install -y etcd-client
```

## Sertifika Bilgilerini Bulmak

etcd'ye dogrudan baglanilmaz, TLS ile korunur. Snapshot almak icin endpoint ve uc adet sertifika yolu gerekir:

| Parametre | Aciklama |
|-----------|----------|
| `--endpoints` | etcd'nin dinledigi adres (`https://127.0.0.1:2379`) |
| `--cacert` | Sertifika otoritesi (CA), sunucuyu dogrular |
| `--cert` | Istemci sertifikasi |
| `--key` | Istemci ozel anahtari |

Bu yollari ezberlemek yerine kubeadm cluster'da etcd static pod manifest'inden okumak en sagligi:

```bash
grep -E "cert|key|trusted|listen" /etc/kubernetes/manifests/etcd.yaml
```

Tipik kubeadm yollari:

```
--cacert   /etc/kubernetes/pki/etcd/ca.crt
--cert     /etc/kubernetes/pki/etcd/server.crt
--key      /etc/kubernetes/pki/etcd/server.key
```

## Snapshot Almak

Tek bir dizine `.db` dosyasi olarak yedek aliyoruz. etcdctl hedef dizini kendisi olusturmaz, onceden `mkdir` ile acmak gerekir.

```bash
mkdir -p /opt/etcd-backup

ETCDCTL_API=3 etcdctl snapshot save /opt/etcd-backup/snapshot.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
```

Basarili olursa:

```
Snapshot saved at /opt/etcd-backup/snapshot.db
```

Bu komut etcd'nin calistigi node'da ve sertifikalara erisimi olan bir yerde calistirilmalidir. Genelde control plane node'una baglanip orada calistirilir.

## Yedegi Dogrulamak

Alinan snapshot saglam mi, icinde ne var diye kontrol etmek icin:

```bash
ETCDCTL_API=3 etcdctl snapshot status /opt/etcd-backup/snapshot.db --write-out=table
```

Ciktida HASH, REVISION, TOTAL KEYS ve TOTAL SIZE bilgilerini iceren bir tablo doner:

```
+----------+----------+------------+------------+
|   HASH   | REVISION | TOTAL KEYS | TOTAL SIZE |
+----------+----------+------------+------------+
| add0401f |   344638 |       1219 |      12 MB |
+----------+----------+------------+------------+
```

Yeni etcd surumlerinde `status` ve `restore` islemleri `etcdctl`'den `etcdutl`'e tasinmistir. `etcdctl` hala calisir ama deprecated uyarisi verir. Ayni tabloyu su sekilde de alabilirsiniz:

```bash
etcdutl snapshot status /opt/etcd-backup/snapshot.db --write-out=table
```

`status` icin endpoint veya sertifika gerekmez, cunku canli etcd'ye degil diskteki dosyaya bakilir.

## Geri Yukleme (Restore)

Restore snapshot'tan yeni bir data dizini olusturur, var olan etcd'nin uzerine yazmaz.

```bash
ETCDCTL_API=3 etcdctl snapshot restore /opt/etcd-backup/snapshot.db \
  --data-dir=/var/lib/etcd-restore
```

Sonrasinda etcd'yi bu yeni dizine bakacak sekilde yonlendirmek gerekir. Static pod manifest'inde (`/etc/kubernetes/manifests/etcd.yaml`) `--data-dir` ve ilgili hostPath volume yeni dizine guncellenir. kubelet manifest degisikligini gorup pod'u otomatik yeniden baslatir.

Restore islemi de offline calisir, sertifika veya endpoint gerekmez.

## Otomatik Yedekleme

Yedegi her gun otomatik almak icin kucuk bir script yazip cron'a baglayabiliriz. Asagidaki script gunluk bir dizin olusturur, snapshot alir ve 7 gunden eski yedekleri siler.

`/opt/scripts/etcd-backup.sh`:

```bash
#!/bin/bash
D=$(date +%d-%m-%y); DIR=/opt/etcd-backup/$D; mkdir -p $DIR
ETCDCTL_API=3 /usr/bin/etcdctl snapshot save --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key $DIR/etcd-backup-$D.db
find /opt/etcd-backup/ -type d -mtime +7 -exec rm -rf {} +
```

Calistirilabilir yapip cron'a ekliyoruz:

```bash
chmod +x /opt/scripts/etcd-backup.sh
```

```bash
crontab -e
```

Her gun saat 03:00'te calismasi icin:

```
0 3 * * * /opt/scripts/etcd-backup.sh >> /var/log/etcd-backup.log 2>&1
```

Cron PATH'i dar oldugu icin script icinde `etcdctl`'in tam yolunu (`/usr/bin/etcdctl`) yazmak gerekir, aksi halde "command not found" alinir. Yolu `which etcdctl` ile dogrulayabilirsiniz.

## Off-site Kopya

Yedegin sadece ayni diskte durmasi tek basina yeterli degildir. Disk giderse veya node comerse yedek de gider. Bunun icin yedegi `rclone` ile uzak bir depolama alanina (ornegin Google Drive) kopyalamak mantiklidir.

Snapshot alindiktan sonra o gunun dizinini uzak depoya kopyalayan satiri script'e ekliyoruz:

```bash
/usr/bin/rclone copy $DIR gdrive:etcd-backup/$D
```

rclone config'inin cron'u calistiran kullanici (genelde root) tarafindan erisilebilir olmasi gerekir. `rclone listremotes` ile remote'un gorundugunu kontrol edebilirsiniz.

## Ozet

```
save     -> canli etcd'ye baglanir -> endpoint + sertifika GEREKIR
status   -> diskteki .db'ye bakar  -> sertifika GEREKMEZ
restore  -> diskteki .db'den acar  -> sertifika GEREKMEZ
```

Akilda tutulacak temel ayrim: `save` islemi sertifika ister, `status` ve `restore` istemez.