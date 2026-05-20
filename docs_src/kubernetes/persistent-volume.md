# Persistent Volume ve Persistent Volume Claim

Podlar gecici (ephemeral) yapilardir. Bir pod kapandiginda veya yeniden basladiginda icerisindeki veriler de kaybolur. Uygulamanin veri saklamasi gerektiginde bu durum ciddi bir sorun olusturur.

Bu sorunu cozmek icin Kubernetes bize `PersistentVolume` ve `PersistentVolumeClaim` objelerini sunar. Bu iki obje birlikte calisir: PersistentVolume (PV) depolama kaynagini tanimlarken, PersistentVolumeClaim (PVC) ise pod'un bu kaynaktan depolama talep etmesini saglar.

## PersistentVolume (PV)

PV, cluster uzerinde olusturulan bir depolama kaynagindir. Pod'lardan bagimsiz olarak yasayan bir objedir; pod kapansa bile PV uzerindeki veriler korunur.

Bir yonetici tarafindan onceden olusturulabilecegi gibi StorageClass yardimiyla dinamik olarak da saglanabilir.

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-example
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: "/mnt/data"
```

- `capacity`: PV'nin depolama kapasitesini belirtir.
- `accessModes`: PV'ye hangi modda erisilecegini belirler.
- `persistentVolumeReclaimPolicy`: Bagli oldugu PVC silindiginde PV'ye ne yapilacagini belirler.
- `hostPath`: Depolamanin gerceklesecegi node uzerindeki dizini belirtir. Production ortaminda `hostPath` yerine NFS, cloud storage gibi cozumler tercih edilir.

### Erisim Modlari (Access Modes)

Uc farkli erisim modu vardir:

- **ReadWriteOnce (RWO)**: Yalnizca tek bir node tarafindan okuma-yazma modunda baglanabilir.
- **ReadOnlyMany (ROX)**: Birden fazla node tarafindan yalnizca okuma modunda baglanabilir.
- **ReadWriteMany (RWX)**: Birden fazla node tarafindan okuma-yazma modunda baglanabilir.

### Reclaim Policy

PVC silindiginde PV'ye ne yapilacagini belirler:

- **Retain**: PV ve icerisindeki veriler korunur. Manuel olarak temizlenip tekrar kullanima hazir hale getirilmesi gerekir.
- **Delete**: PV ve icerisindeki veriler otomatik olarak silinir.
- **Recycle**: Icerik silinir ve PV yeniden kullanima hazir hale getirilir. (Deprecated, kullanimi onerilmez)

## PersistentVolumeClaim (PVC)

PVC, pod'un bir PV'den depolama talep etmek icin kullandigi objedir. PVC olusturuldugunda Kubernetes belirtilen ozelliklere uygun bir PV arar ve eslesirse bu ikisi birbirine baglanir (**Bound** durumuna gecer).

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-example
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```

- `accessModes`: Talep edilen erisim modu. Baglanacak PV'nin desteklemesi gerekir.
- `resources.requests.storage`: Talep edilen minimum depolama kapasitesi.

PVC olusturulduktan sonra `kubectl get pvc` komutu ile durumu kontrol edilebilir. Uygun bir PV bulunamazsa PVC `Pending` durumunda bekler.

```bash
kubectl get pv
kubectl get pvc
```

## Pod Icerisinde Kullanim

PVC olusturulduktan sonra pod tanimi icerisinde `volumes` ve `volumeMounts` alanlari ile pod'a baglanir.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: uygulama-pod
spec:
  containers:
  - name: uygulama
    image: nginx:1.22.1
    volumeMounts:
    - mountPath: "/usr/share/nginx/html"
      name: pvc-depolama
  volumes:
  - name: pvc-depolama
    persistentVolumeClaim:
      claimName: pvc-example
```

- `volumes` alaninda hangi PVC'nin kullanilacagi `claimName` ile belirtilir.
- `volumeMounts` alaninda bu volumun container icerisinde hangi dizine baglanacagi tanimlanir.

***Not: Birden fazla pod ayni anda ayni PVC'yi okuma-yazma modunda kullanmak istiyorsa PV'nin erisim modunun `ReadWriteMany` olmasi gerekir. `ReadWriteOnce` modundaki bir PV ayni anda yalnizca tek bir node tarafindan baglanabilir.***

## NFS ile PV ve PVC Kullanimi

`hostPath` yalnizca tek bir node uzerinde calisir ve o node'a bagimlidir. Pod farkli bir node'a schedule edildiginde veriye erisemez. Bunu cozmek icin tum node'lardan erisilebilen paylasimli bir depolama alani kullanmak gerekir. NFS (Network File System) bu amac icin yaygin tercihlerden biridir.

Oncelikle NFS sunucu adresi ve paylasim yolu bilinmesi gerekir. Asagidaki ornekte NFS sunucusu `192.168.1.100` adresinde, paylasilan dizin ise `/srv/nfs/kubernetes`'tir.

### NFS PV Tanimi

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-nfs
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  nfs:
    server: 192.168.1.100
    path: "/srv/nfs/kubernetes"
```

- `nfs.server`: NFS sunucusunun IP adresi veya hostname'i.
- `nfs.path`: NFS sunucusu uzerinde paylasilan dizin. Onceden olusturulmus olmasi gerekir.
- `accessModes` olarak `ReadWriteMany` kullanildi; NFS birden fazla node tarafindan ayni anda okunup yazilabilir.

***Not: NFS paylasiminin Kubernetes node'larinda calisabilmesi icin her node uzerinde `nfs-common` (Debian/Ubuntu) veya `nfs-utils` (RHEL/CentOS) paketinin yuklu olmasi gerekir.***

### NFS PVC Tanimi

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-nfs
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
```

PVC olusturuldugunda Kubernetes kapasite ve erisim modu eslestiginden `pv-nfs` ile otomatik olarak eslesir ve `Bound` durumuna gecer.

```bash
kubectl apply -f pv-nfs.yaml
kubectl apply -f pvc-nfs.yaml
kubectl get pv,pvc
```

### Pod Icerisinde Kullanim

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: uygulama-pod
spec:
  containers:
  - name: uygulama
    image: nginx:1.22.1
    volumeMounts:
    - mountPath: "/usr/share/nginx/html"
      name: nfs-depolama
  volumes:
  - name: nfs-depolama
    persistentVolumeClaim:
      claimName: pvc-nfs
```

Pod hangi node'a schedule edilirse edilsin NFS uzerinden ayni veriye erisir. Birden fazla pod ayni PVC'yi ayni anda kullanabilir.
