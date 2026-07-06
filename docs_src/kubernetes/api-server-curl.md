# API Server'a curl ile Erismek

`kubectl`, aslinda arka planda Kubernetes API Server'a HTTP istekleri atan bir istemcidir. Her `kubectl get pods` komutu, API Server'daki `/api/v1/namespaces/.../pods` gibi bir endpoint'e yapilan bir REST cagrisidir. Bu yuzden istersek `kubectl` olmadan, dogrudan `curl` ile de API Server'a konusabiliriz.

Bu neden gerekir? Cluster icinde calisan bir uygulamanin (ornegin pod'lari izleyen bir operator, bir CI job'i veya bir health-check scripti) API Server ile konusmasi gerektiginde genelde `kubectl` kurulu olmaz. Bunun yerine uygulama, dogrudan HTTP ile API'ye erisir. Bu erisimin iki temel gereksinimi vardir: **API Server'in adresi** ve **bir kimlik (token veya sertifika)**.

**API Server'a erisim iki parcadan olusur: nereye baglanacagimiz (adres + CA sertifikasi) ve kim oldugumuz (bir ServiceAccount token'i veya istemci sertifikasi).**

## Yontem 1: Pod Icinden Erismek

Cluster icindeki her pod'a, kullandigi ServiceAccount'un bilgileri otomatik olarak **mount edilir**. Bu bilgiler her pod'da su sabit dizinde bulunur:

```text
/var/run/secrets/kubernetes.io/serviceaccount/
├── token       # ServiceAccount'un JWT token'i (kimligimiz)
├── ca.crt      # API Server'i dogrulayan CA sertifikasi
└── namespace   # Pod'un icinde bulundugu namespace
```

Ayrica API Server'in adresi pod icinde iki ortam degiskeni olarak hazir gelir: `KUBERNETES_SERVICE_HOST` ve `KUBERNETES_SERVICE_PORT`. Yani pod icinden API Server'a erismek icin disaridan hicbir bilgi tasimana gerek yoktur; hepsi zaten oradadir.

Bir pod'un icine girip (`kubectl exec -it <pod> -- sh`) asagidaki komutlari calistirabilirsin:

```bash
# ServiceAccount bilgilerini degiskenlere al
APISERVER=https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT}
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
NAMESPACE=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)

# API Server'a "ben kimim?" diye sor (en basit dogrulama)
curl --cacert ${CACERT} \
     --header "Authorization: Bearer ${TOKEN}" \
     ${APISERVER}/api

# Kendi namespace'indeki pod'lari listele
curl --cacert ${CACERT} \
     --header "Authorization: Bearer ${TOKEN}" \
     ${APISERVER}/api/v1/namespaces/${NAMESPACE}/pods
```

- `--cacert`: API Server'in sertifikasini dogrulamak icin CA. Bunu vermezsen TLS dogrulamasi basarisiz olur (test icin `-k` ile atlanabilir ama uretimde yapilmamalidir).
- `Authorization: Bearer <token>`: Kimligimizi tasidigimiz basliktir. Token, hangi ServiceAccount oldugumuzu API Server'a soyler.

***Not: Token'i ekrana basip elle kopyalamaya calisma; JWT token'lari cok uzundur ve genelde satir sonu/bosluk sorunlari yasanir. Yukaridaki gibi dogrudan dosyadan degiskene almak (`$(cat .../token)`) en saglikli yontemdir.***

### Yetki (RBAC) Gerekir

Token'in olmasi, o istegin **yetkili** oldugu anlamina gelmez. API Server once kimligi dogrular (authentication), ardindan bu ServiceAccount'un istenen islemi yapmaya yetkisi var mi diye RBAC kurallarina bakar (authorization). Eger ServiceAccount'a gerekli Role/RoleBinding verilmemisse, curl `403 Forbidden` doner:

```json
{
  "kind": "Status",
  "status": "Failure",
  "message": "pods is forbidden: User \"system:serviceaccount:dev:uygulama-sa\" cannot list resource \"pods\"...",
  "code": 403
}
```

Bu durumda ServiceAccount'a ilgili yetkiyi bir RoleBinding ile vermen gerekir. Detaylar icin RBAC dokumanina bakabilirsin.

## Yontem 2: Bir ServiceAccount Token'i ile Disaridan Erismek

Cluster disindan (ornegin kendi makinenden veya bir CI runner'dan) belirli bir ServiceAccount kimligiyle API Server'a erismek istersen, o ServiceAccount icin bir token uretip kullanabilirsin.

Once (gerekiyorsa) bir ServiceAccount ve ona yetki veren binding olustur:

```bash
kubectl create serviceaccount uygulama-sa -n dev
kubectl create rolebinding uygulama-sa-binding \
  --clusterrole=view \
  --serviceaccount=dev:uygulama-sa -n dev
```

Ardindan bu ServiceAccount icin kisa omurlu bir token uret (Kubernetes 1.24+):

```bash
TOKEN=$(kubectl create token uygulama-sa -n dev)
```

API Server'in adresini ve CA sertifikasini mevcut kubeconfig'inden alabilirsin:

```bash
# API Server adresi
APISERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')

# CA sertifikasini bir dosyaya cikar
kubectl config view --minify --raw \
  -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 -d > /tmp/ca.crt
```

Simdi disaridan curl ile erisebilirsin:

```bash
curl --cacert /tmp/ca.crt \
     --header "Authorization: Bearer ${TOKEN}" \
     ${APISERVER}/api/v1/namespaces/dev/pods
```

***Not: `kubectl create token` ile uretilen token varsayilan olarak **kisa omurludur** (genelde 1 saat) ve suresi dolunca gecersiz olur. Suryi uzatmak icin `--duration=24h` gibi bir deger verebilirsin. Eskiden ServiceAccount'lara otomatik olusan kalici token'lar (Secret icinde) vardi; Kubernetes 1.24 ile bu davranis kaldirildi. Uzun omurlu bir token gerekiyorsa manuel olarak `kubernetes.io/service-account-token` tipinde bir Secret olusturman gerekir, ancak guvenlik acisindan mumkun oldugunca kisa omurlu token tercih edilmelidir.***

## Yontem 3: kubectl proxy (En Pratik Test Yolu)

Sadece hizlica denemek istiyorsan, kimlik dogrulama ve TLS ile ugrasmadan `kubectl proxy` kullanabilirsin. Bu komut, senin mevcut kubeconfig kimligini kullanarak API Server'a yerel bir vekil (proxy) acar:

```bash
# Yerel 8001 portunda proxy baslat
kubectl proxy --port=8001 &

# Artik token/CA olmadan localhost uzerinden erisebilirsin
curl http://localhost:8001/api/v1/namespaces/dev/pods
```

`kubectl proxy` arkaplanda senin kubeconfig'indeki kimlik bilgilerini kullandigi icin curl komutuna token veya CA eklemene gerek kalmaz. Yalnizca yerel gelistirme ve kesif (API endpoint'lerini gezmek) icin idealdir.

## Sik Kullanilan API Endpoint'leri

```bash
# API gruplarini ve versiyonlarini kesfet
curl .../api
curl .../apis

# Core (v1) kaynaklar
curl .../api/v1/namespaces                       # tum namespace'ler
curl .../api/v1/namespaces/dev/pods              # dev'deki pod'lar
curl .../api/v1/namespaces/dev/pods/uygulama-pod # tek bir pod
curl .../api/v1/nodes                            # node'lar

# apps grubu (Deployment, ReplicaSet, DaemonSet...)
curl .../apis/apps/v1/namespaces/dev/deployments

# Sonucu okunabilir yapmak icin jq'ya boru
curl -s ... | jq '.items[].metadata.name'
```

***Not: Core kaynaklar (`pods`, `services`, `configmaps` gibi) `/api/v1/...` altinda; digerleri (`deployments`, `ingresses` gibi) ise ait olduklari API grubunda `/apis/<grup>/<versiyon>/...` altinda bulunur. Bir kaynagin tam yolundan emin degilsen, `kubectl get pods -v=8` gibi `-v=8` verbose seviyesiyle `kubectl` calistir; hangi URL'e istek attigini ciktida acikca gorursun.***
