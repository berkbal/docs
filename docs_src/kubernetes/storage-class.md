# StorageClass Nedir?

`PersistentVolume` ve `PersistentVolumeClaim` konusunda, PV'lerin bir yonetici tarafindan onceden manuel olarak olusturulabilecegini gormustuk. Bu yonteme **static provisioning** denir. Ancak buyuk ve dinamik ortamlarda her PVC talebi icin yoneticinin elle PV olusturmasi pratik degildir.

StorageClass, bu sorunu cozerek **dynamic provisioning** (dinamik saglama) imkani sunar. Bir pod depolama talep ettiginde (PVC olusturdugunda), StorageClass uygun depolama kaynagini otomatik olarak olusturur. Boylece yoneticinin onceden PV hazirlamasina gerek kalmaz.

**StorageClass, depolamanin nasil ve hangi altyapida saglanacagini tanimlayan bir sablondur.**

## Calisma Mantigi

Dinamik saglama su sirayla ilerler:

1. Yonetici bir veya birden fazla StorageClass tanimlar.
2. Gelistirici bir PVC olusturur ve icinde kullanmak istedigi StorageClass'i belirtir.
3. StorageClass'a bagli olan provisioner, talebe uygun bir PV'yi otomatik olarak olusturur.
4. Olusan PV, PVC'ye baglanir (bound) ve pod depolamayi kullanmaya baslar.

## Temel StorageClass Tanimi

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp3
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```

- `provisioner`: Depolamayi saglayacak eklentidir. Hangi altyapinin kullanilacagini belirler (AWS EBS, GCE PD, Ceph, NFS vb.).
- `parameters`: Provisioner'a ozel ayarlardir (disk tipi, IOPS, filesystem vb.). Her provisioner kendi parametrelerini bekler.
- `reclaimPolicy`: PVC silindiginde olusan PV'ye ne olacagini belirler (`Delete` veya `Retain`).
- `volumeBindingMode`: PV'nin ne zaman olusturulup baglanacagini belirler.
- `allowVolumeExpansion`: `true` ise PVC'yi buyuterek volume genisletmeye izin verir.

## Provisioner

Provisioner, gercek depolamayi olusturan bilesendir. Kubernetes bazi dahili (in-tree) provisioner'lar ile gelir fakat gunumuzde standart yontem **CSI (Container Storage Interface)** surucularidir. Cloud saglayicilar ve depolama sistemleri kendi CSI surucularini sunar.

Ornek provisioner degerleri:

- `kubernetes.io/aws-ebs` veya `ebs.csi.aws.com` (AWS)
- `pd.csi.storage.gke.io` (GCP)
- `disk.csi.azure.com` (Azure)
- `rancher.io/local-path` (local-path-provisioner, test/dev ortamlari icin yaygin)

## reclaimPolicy

StorageClass uzerinden dinamik olusturulan PV'lerin varsayilan reclaim policy'si `Delete`'tir.

- **Delete**: PVC silindiginde, bagli PV ve arkasindaki gercek depolama (disk) de otomatik silinir. Veri kaybi olur.
- **Retain**: PVC silinse bile PV ve veri korunur. PV `Released` durumuna gecer; tekrar kullanilmadan once manuel mudahale gerekir.

**Not: Production ortaminda kritik verilerde `Retain` tercih edilmesi, yanlislikla veri kaybinin onune gecer.**

## volumeBindingMode

PV'nin ne zaman olusturulup PVC'ye baglanacagini kontrol eder.

- **Immediate**: PVC olusturuldugu an PV de hemen olusturulur ve baglanir. Pod'un hangi node'a gidecegi henuz belli olmadigi icin, volume yanlis bir zone'da olusabilir.
- **WaitForFirstConsumer**: PV olusturulmasi, PVC'yi kullanan pod schedule edilene kadar ertelenir. Boylece volume, pod'un calisacagi node/zone ile ayni yerde olusturulur. Cok zonlu (multi-zone) cluster'larda onerilen moddur.

## PVC ile Kullanimi

Bir PVC, kullanmak istedigi StorageClass'i `storageClassName` alani ile belirtir. StorageClass eslestiginde PV dinamik olarak olusturulur.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: standard
  resources:
    requests:
      storage: 10Gi
```

- `storageClassName`: Kullanilacak StorageClass'in adi. Bu alan bos birakilirsa default StorageClass devreye girer.

## Default StorageClass

Bir cluster'da bir StorageClass `default` olarak isaretlenebilir. PVC, `storageClassName` belirtmediginde bu default class kullanilir. Default class, asagidaki annotation ile tanimlanir:

```yaml
metadata:
  name: standard
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
```

**Not: Bir cluster'da yalnizca bir tane default StorageClass olmasi onerilir. Birden fazla default tanimlanirsa Kubernetes hangisini secegini bilemez ve PVC beklemede kalabilir.**

## Kullanisli Komutlar

```bash
kubectl get storageclass
kubectl get sc
kubectl describe sc standard
kubectl get pvc
kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```
