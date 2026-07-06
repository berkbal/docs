# Kustomize Nedir?

Helm, uygulamalari sablonlar ve `{{ }}` degiskenleriyle paketler. Ancak bazen istedigin sey bir sablon dili ogrenmek degil, sadece elindeki **duz YAML manifestlerini** farkli ortamlar icin biraz degistirmektir: dev'de 1 replica, prod'da 5 replica; dev'de bir imaj etiketi, prod'da baskasi. Her ortam icin dosyalari kopyalayip elle degistirmek yerine, ortak bir taban tutup uzerine ortama ozel yamalar (patch) uygulayabilmek istersin.

Kustomize tam olarak bunu yapar. Sablon veya degisken kullanmaz; **var olan YAML dosyalarini oldugu gibi birakip, uzerlerine katmanli degisiklikler uygular**. Bu yaklasima "overlay" (katman) mantigi denir. En guzel yani, Kustomize'in `kubectl` icine gomulu olmasidir; ayrica bir sey kurmana gerek yoktur.

**Kustomize, duz Kubernetes YAML dosyalarini sablonsuz bir sekilde, ortak bir taban (base) ve ortama ozel katmanlar (overlay) uzerinden ozellestirmeyi saglayan bir aractir.**

## Temel Kavramlar

- **base**: Tum ortamlarin paylastigi ortak manifestler (deployment.yaml, service.yaml...) ve bunlari listeleyen bir `kustomization.yaml`.
- **overlay**: Belirli bir ortam (dev, prod...) icin base'i referans alan ve uzerine degisiklik uygulayan katman.
- **kustomization.yaml**: Kustomize'in giris noktasidir. Hangi kaynaklarin dahil edilecegini ve nasil degistirilecegini bu dosya tanimlar.

## Dizin Yapisi

Tipik bir Kustomize projesi base ve overlay olarak ikiye ayrilir:

```text
myapp/
├── base/
│   ├── kustomization.yaml
│   ├── deployment.yaml
│   └── service.yaml
└── overlays/
    ├── dev/
    │   └── kustomization.yaml
    └── prod/
        ├── kustomization.yaml
        └── replica-patch.yaml
```

## Base Katmani

Base, degisiklige ugramamis normal manifestlerdir. `base/deployment.yaml` tamamen standart bir YAML'dir; icinde hicbir degisken yoktur:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: web
          image: nginx:1.25
          ports:
            - containerPort: 80
```

`base/kustomization.yaml` ise hangi dosyalarin bu base'e dahil oldugunu listeler:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
```

## Overlay Katmani

Overlay, base'i referans alir ve uzerine ortama ozel degisiklikleri ekler. Ornegin `overlays/prod/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base          # Base'i oldugu gibi al

namePrefix: prod-       # Tum obje isimlerinin basina "prod-" ekle
namespace: production   # Hepsini production namespace'ine koy

commonLabels:
  ortam: prod           # Tum objelere bu label'i ekle

images:
  - name: nginx         # base'deki nginx imajini
    newTag: "1.26"      # bu etiketle degistir

patches:
  - path: replica-patch.yaml   # replica sayisini degistiren yama
```

Yamayi tutan `overlays/prod/replica-patch.yaml` ise yalnizca **degistirmek istedigin alanlari** icerir; geri kalani base'den gelir:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 5
```

Kustomize bu yamayi base'deki `web` deployment'i ile birlestirir (strategic merge): sonuc, replica sayisi 5, imaji `nginx:1.26`, ismi `prod-web`, namespace'i `production` olan bir deployment olur. Base dosyasina hic dokunulmaz.

## Ciktiyi Uretmek ve Uygulamak

Kustomize `kubectl` icine gomuludur; `-k` bayragi ile bir overlay dizinini isaret edersin:

```bash
# Ciktiyi uygulamadan gormek (uretilen son YAML'i basar)
kubectl kustomize overlays/prod

# Overlay'i cluster'a uygulamak
kubectl apply -k overlays/prod

# Dev ortamini uygulamak
kubectl apply -k overlays/dev

# Uygulamadan once ne uygulanacagini gormek (dry run)
kubectl apply -k overlays/prod --dry-run=client -o yaml
```

***Not: `kubectl kustomize <dizin>` komutu, uretilen nihai YAML'i cluster'a dokunmadan ekrana basar. Bir yamanin gercekten dogru sonucu urettigini dogrulamanin en pratik yoludur.***

## Sik Kullanilan Alanlar

`kustomization.yaml` icinde en cok kullanilan alanlar:

| Alan | Ne yapar |
|------|----------|
| `resources` | Dahil edilecek YAML dosyalari veya diger kustomize dizinleri |
| `namePrefix` / `nameSuffix` | Tum obje isimlerinin basina/sonuna ek koyar |
| `namespace` | Tum objeleri belirtilen namespace'e tasir |
| `commonLabels` | Tum objelere ortak label ekler |
| `images` | Imaj adini/etiketini degistirir (dosyaya dokunmadan) |
| `patches` | Belirli alanlari degistiren yamalar uygular |
| `configMapGenerator` | Dosya veya degerlerden ConfigMap uretir |

***Not: `configMapGenerator` ile uretilen ConfigMap'lerin ismine Kustomize otomatik olarak bir hash ekler. Icerik degistiginde hash de degisir; bu sayede ConfigMap guncellendiginde bagli podlar otomatik yeniden baslatilir. Bu, elle ConfigMap yonetiminde sik yasanan "degisti ama pod eski degeri okuyor" sorununu cozer.***

## Helm mi, Kustomize mi?

Ikisi de ayni amaca (uygulamalari farkli ortamlar icin ozellestirmek) hizmet eder ama yaklasimlari farklidir:

| | Helm | Kustomize |
|---|------|-----------|
| Yontem | Sablon + degiskenler (`{{ }}`) | Duz YAML + katmanli yamalar |
| Kurulum | Ayri kurulmasi gerekir | `kubectl -k` ile gomulu gelir |
| Surumleme / rollback | Var (release gecmisi) | Yok (git ile yapilir) |
| Hazir paket ekosistemi | Cok genis (chart repolari) | Yok |
| Ogrenme egrisi | Sablon dili gerektirir | Dogrudan YAML, daha basit |

Pratikte ikisi birlikte de kullanilir: hazir bir Helm chart'i alinip ciktisi Kustomize ile son bir kez ozellestirilebilir. Basit, kendi yazdigin manifestler icin Kustomize genelde yeterlidir; genis, parametrik ve dagitilacak paketler icin Helm daha uygundur.
