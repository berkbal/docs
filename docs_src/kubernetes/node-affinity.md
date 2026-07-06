# Node Affinity ve nodeSelector

Taint ve Toleration konusunda podlari belirli node'lardan **uzak tutan** (itme) mekanizmayi gormustuk. Cogu zaman ise tam tersine ihtiyac duyariz: bir podu belirli ozelliklere sahip node'lara **cekmek** isteriz. Ornegin bir makine ogrenmesi podunun mutlaka GPU'lu bir node'a, bir veritabani podunun ise SSD diski olan bir node'a gitmesini isteyebiliriz.

Kubernetes scheduler'i varsayilan olarak podu uygun herhangi bir node'a yerlestirir. Podun **hangi node'a** gidecegini yonlendirmek istiyorsak, bunu node'lara verilen label'lar uzerinden yapariz. `nodeSelector` ve `nodeAffinity` tam olarak bu ise yarar.

**nodeSelector ve nodeAffinity, bir podun node label'larina gore belirli node'lara yerlestirilmesini saglayan "cekme" mekanizmalaridir. Taint/Toleration iter, affinity ceker.**

## Once Node'a Label Vermek

Affinity kurallari node label'lariyla eslesir. O yuzden once ilgili node'lari etiketlemek gerekir:

```bash
# node1'e disk tipi label'i ekle
kubectl label nodes node1 disktype=ssd

# Node'un label'larini gormek
kubectl get nodes --show-labels
kubectl get nodes -L disktype        # sadece belirli label'i kolon olarak goster
```

***Not: Kubernetes node'lara varsayilan olarak bircok label ekler (`kubernetes.io/hostname`, `kubernetes.io/arch`, `topology.kubernetes.io/zone` gibi). Bunlari da affinity kurallarinda dogrudan kullanabilirsin; her seye kendi label'ini eklemek zorunda degilsin.***

## nodeSelector (En Basit Yol)

`nodeSelector`, podu yalnizca belirtilen label'lara **birebir sahip** node'lara yerlestirir. En basit ama en kati yontemdir: eslesme yoksa pod `Pending` durumunda bekler.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ssd-pod
spec:
  nodeSelector:
    disktype: ssd
  containers:
    - name: uygulama
      image: nginx:1.25
```

Bu pod yalnizca `disktype=ssd` label'ina sahip node'lara yerlesir. Sadece "sunlara sahip node" diyebilirsin; "su olmasin" ya da "su veya bu" gibi esnek ifadeler kuramazsin. Iste bu esneklik icin `nodeAffinity` gerekir.

## nodeAffinity

nodeAffinity, nodeSelector'un daha esnek ve ifade gucu yuksek halidir. Iki tur kural sunar; ikisi arasindaki fark **zorunluluk** derecesidir:

| Kural turu | Anlami |
|------------|--------|
| `requiredDuringSchedulingIgnoredDuringExecution` | **Zorunlu**. Kurala uyan node yoksa pod schedule edilmez (`Pending` kalir). nodeSelector'un esnek surumu gibidir. |
| `preferredDuringSchedulingIgnoredDuringExecution` | **Tercih**. Scheduler once bu node'lari dener; bulamazsa yine de baska bir node'a yerlestirir. "Mumkunse su, degilse olsun." |

***Not: Iki kuraldaki `IgnoredDuringExecution` kismi sunu anlatir: kurallar yalnizca **schedule ani** icin gecerlidir. Pod bir node'a yerlestikten sonra o node'un label'i degisse bile calisan pod tahliye edilmez. (Taint'teki `NoExecute` etkisinin aksine, affinity calisan podu node'dan atmaz.)***

### Zorunlu Kural (required)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: disktype
                operator: In
                values:
                  - ssd
                  - nvme
  containers:
    - name: uygulama
      image: nginx:1.25
```

Bu pod, `disktype` label'i `ssd` **veya** `nvme` olan node'lara yerlesir. nodeSelector ile yapamadigimiz "su veya bu" ifadesini burada `In` operatoru ve `values` listesiyle kurdik.

### Tercih Edilen Kural (preferred)

```yaml
spec:
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 1
          preference:
            matchExpressions:
              - key: disktype
                operator: In
                values:
                  - ssd
```

`weight` (1-100) her tercihe bir agirlik verir. Scheduler node'lari puanlarken bu agirliklari toplar ve en yuksek puanli uygun node'u secer. Uyan node yoksa pod yine de bir yere yerlesir; kural yalnizca bir **tercihtir**, engel degildir.

### Operatorler

`matchExpressions` icinde kullanilan operatorler:

- **In**: Label degeri, verilen listeden biriyse.
- **NotIn**: Label degeri listede yoksa (dislama icin kullanilir).
- **Exists**: Label anahtari node'da varsa (degerine bakilmaz).
- **DoesNotExist**: Label anahtari node'da yoksa.
- **Gt** / **Lt**: Sayisal karsilastirma (buyuktur / kucuktur).

`NotIn` ve `DoesNotExist`, "su node'lara **gitme**" demenin (anti-affinity benzeri) yoludur.

## Pod Affinity ve Pod Anti-Affinity

nodeAffinity podu **node label'larina** gore yerlestirir. Bazen ise podu diger **podlara gore** konumlandirmak isteriz:

- **podAffinity**: Podu, belirli podlarin **yaninda** calistir (ornegin bir cache podunu, kullanan uygulamayla ayni node'da tutmak — dusuk gecikme icin).
- **podAntiAffinity**: Podu, belirli podlardan **uzakta** calistir (ornegin ayni uygulamanin 3 replikasini 3 ayri node'a dagitmak — yuksek erisilebilirlik icin).

```yaml
spec:
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchLabels:
              app: web
          topologyKey: kubernetes.io/hostname
```

Bu kural, `app: web` etiketli podlarin ayni node'a (`topologyKey: kubernetes.io/hostname`) yerlesmesini engeller; her replika ayri bir node'a dagitilir.

***Not: `topologyKey`, "yakinlik/uzaklik hangi seviyede olculecek?" sorusunu yanitlar. `kubernetes.io/hostname` node bazinda dagitir; `topology.kubernetes.io/zone` ise ayni availability zone'a dagitmayi/dagitmamayi kontrol eder. Anti-affinity ile podlari zonlara yayarak bir node veya zone coktugunde servisin ayakta kalmasini saglayabilirsin.***

## nodeSelector vs Affinity vs Taint

Uc mekanizma sik karistirilir; ozeti:

| Mekanizma | Ne yapar | Bakis acisi |
|-----------|----------|-------------|
| `nodeSelector` | Podu belirli label'li node'a **ceker** (kati) | Pod → node |
| `nodeAffinity` | Podu node'a **ceker** (esnek: zorunlu/tercih) | Pod → node |
| Taint / Toleration | Node'a pod gelmesini **engeller** (itme) | Node → pod |

Bu ikisi birbirini tamamlar: bir node'u ozel is yuku icin ayirmak istiyorsan hem node'a **taint** koyarsin (baskalari gelmesin) hem de o is yukunun poduna **nodeAffinity/nodeSelector** verirsin (bu pod oraya gitsin). Yalnizca affinity verirsen pod oraya gider ama node bos oldugunda baska podlar da oraya yerlesebilir; ikisini birlikte kullanmak node'u gercekten ayirir.

## Kullanisli Komutlar

```bash
# Node'a label ekle / kaldir
kubectl label nodes node1 disktype=ssd
kubectl label nodes node1 disktype-

# Node label'larini gor
kubectl get nodes --show-labels
kubectl get nodes -L disktype

# Bir pod neden Pending kaldi? (uygun node bulunamadiysa sebebini yazar)
kubectl describe pod gpu-pod | grep -A5 Events

# Podlarin hangi node'a yerlestigini gor
kubectl get pods -o wide
```

***Not: Bir pod `Pending` durumunda takildiysa `kubectl describe pod` ciktisindaki Events bolumu genelde `0/3 nodes are available: ... didn't match node selector/affinity` gibi net bir sebep verir. Affinity kurallari cok kati oldugunda pod hicbir node'a yerlesemez; boyle durumda `required` yerine `preferred` kullanmayi degerlendir.***
