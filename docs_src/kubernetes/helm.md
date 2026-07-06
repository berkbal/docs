# Helm Nedir?

Bir uygulamayi Kubernetes'e kurmak icin genellikle tek bir YAML yetmez: Deployment, Service, ConfigMap, Secret, Ingress derken bir uygulama icin onlarca manifest dosyasi ortaya cikar. Ayni uygulamayi farkli ortamlarda (dev, staging, prod) biraz degistirerek kurmak istediginde ise bu dosyalari kopyalayip elle degistirmek zorunda kalirsin. Bu hem zahmetli hem de hataya cok acik bir yontemdir.

Helm, bu sorunu Kubernetes icin bir **paket yoneticisi** olarak cozer. Linux'taki `apt` veya `yum`'un uygulamalari paketleyip kurmasi gibi, Helm de bir uygulamanin tum Kubernetes objelerini tek bir paket (chart) halinde toplar; bu paketi parametrelerle kurmani, guncellemeni ve geri almani saglar.

**Helm, Kubernetes uygulamalarini sablonlanabilir paketler (chart) halinde tanimlayip kurmayi, surumlemeyi ve yonetmeyi saglayan paket yoneticisidir.**

## Temel Kavramlar

Helm uc temel kavram etrafinda doner:

- **Chart**: Bir uygulamayi olusturan tum Kubernetes manifestlerinin sablonlarini ve varsayilan degerlerini iceren pakettir. `apt`'deki `.deb` paketinin karsiligidir.
- **Release**: Bir chart'in cluster'a kurulmus **bir ornegidir**. Ayni chart, farkli isimlerle birden fazla kez kurulabilir; her kurulum ayri bir release'dir.
- **Repository**: Chart'larin yayinlandigi ve indirildigi depodur. `apt`'nin paket depolarinin karsiligidir.

## Chart Yapisi

Bir chart, belirli bir dizin yapisina sahiptir:

```text
mychart/
├── Chart.yaml          # Chart'in adi, surumu, aciklamasi (meta bilgi)
├── values.yaml         # Sablonlarda kullanilan varsayilan degerler
├── templates/          # Sablonlanmis Kubernetes manifestleri
│   ├── deployment.yaml
│   ├── service.yaml
│   └── _helpers.tpl    # Tekrar kullanilan sablon parcalari
└── charts/             # Bu chart'in bagimli oldugu diger chart'lar
```

- `Chart.yaml`: Chart'in kimligidir; adi, surumu ve uygulama surumu burada tutulur.
- `values.yaml`: Sablonlarin okudugu varsayilan degerler. Kurulum sirasinda bu degerler ezilebilir.
- `templates/`: Icinde Go template sozdizimi ile yazilmis manifestler bulunur. Kurulumda bu sablonlar `values` ile birlestirilerek gercek YAML'a donusur.

## Sablon (Template) Mantigi

`templates/` altindaki dosyalar duz YAML degil, icine `{{ }}` ile degiskenler gomulmus sablonlardir. Bu sayede ayni chart farkli degerlerle kurulabilir. Ornek bir `deployment.yaml` sablonu:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-web
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}-web
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}-web
    spec:
      containers:
        - name: web
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          ports:
            - containerPort: {{ .Values.service.port }}
```

- `.Release.Name`: Kurulum sirasinda verdigin release adi (ornegin `helm install frontend ...` dedigin `frontend`).
- `.Values.xxx`: `values.yaml` dosyasindan (veya `--set`/`-f` ile ezilerek) gelen degerler.

Karsilik gelen `values.yaml`:

```yaml
replicaCount: 3

image:
  repository: nginx
  tag: "1.25"

service:
  port: 80
```

Boylece ayni chart, prod ortaminda `replicaCount: 5`, dev ortaminda `replicaCount: 1` ile kurulabilir; tek fark degerlerdir, sablon aynidir.

## Degerleri Ezmek (Override)

Kurulumda varsayilan degerleri iki yolla degistirebilirsin:

```bash
# Tek tek deger ezmek
helm install frontend ./mychart --set replicaCount=5 --set image.tag=1.26

# Ayri bir values dosyasiyla (ortam bazli en temiz yontem)
helm install frontend ./mychart -f values-prod.yaml
```

`-f` ile verilen dosya, chart icindeki `values.yaml`'in uzerine biner: yalnizca belirtilen alanlar ezilir, geri kalani varsayilan kalir. Ortam bazli (`values-dev.yaml`, `values-prod.yaml`) dosyalar tutmak en yaygin ve temiz yontemdir.

## Kurulum, Guncelleme ve Geri Alma

Helm'in en guclu yani, kurulumlari **surumlemesidir**. Her `install` ve `upgrade` bir revizyon olusturur; bir sey ters giderse onceki revizyona geri donebilirsin.

```bash
# Kurulum (release adi: frontend)
helm install frontend ./mychart

# Guncelleme (yeni revizyon olusur)
helm upgrade frontend ./mychart --set image.tag=1.26

# install/upgrade birlesik: yoksa kur, varsa guncelle
helm upgrade --install frontend ./mychart -f values-prod.yaml

# Revizyon gecmisini gor
helm history frontend

# Onceki revizyona geri don
helm rollback frontend 1
```

***Not: `helm upgrade --install` (kisaca "upsert") CI/CD hatlarinda en cok kullanilan komuttur. Release'in daha once kurulup kurulmadigini kontrol etmene gerek kalmaz; yoksa kurar, varsa gunceller.***

## Hazir Chart Kullanmak (Repository)

Kendi chart'ini yazmak zorunda degilsin; populer uygulamalarin (nginx, postgresql, prometheus...) hazir chart'lari repolarda yayinlanir:

```bash
# Repo ekle ve guncelle
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Chart ara
helm search repo postgresql

# Repodan kur
helm install veritabani bitnami/postgresql --set auth.database=uygulama_db
```

## Kullanisli Komutlar

```bash
# Kurulu release'leri listele
helm list
helm list -A                       # tum namespace'lerde

# Sablonlarin uretecegi gercek YAML'i cluster'a uygulamadan gormek (cok faydali)
helm template frontend ./mychart -f values-prod.yaml

# Kurulmadan once dogrulama / kuru calisma (dry run)
helm install frontend ./mychart --dry-run --debug

# Bir release'in kullandigi degerleri gor
helm get values frontend

# Release'i tamamen kaldir
helm uninstall frontend
```

***Not: `helm template` ve `--dry-run`, degistigin bir sablonun gercekte hangi YAML'i uretecegini cluster'i kirletmeden gormenin en pratik yoludur. Bir upgrade oncesi ciktiyi kontrol etmek, beklenmedik degisiklikleri onceden yakalar.***
