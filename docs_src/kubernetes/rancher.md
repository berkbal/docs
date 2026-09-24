# Rancher Nedir?

Bir Kubernetes cluster'ini `kubectl` ile yonetmek mumkundur, ancak cluster sayisi arttikca islem yuku hizla buyur. Her cluster icin ayri kubeconfig tutmak, kimin hangi cluster'da hangi yetkiye sahip oldugunu takip etmek, uygulamalari tek tek kurmak ve tum bunlarin durumunu izlemek zamanla yonetilemez hale gelir.

Rancher, bu sorunu bir **cluster yonetim platformu** olarak cozer. Kendisi de bir uygulama olarak calisir ve birden fazla Kubernetes cluster'ini tek bir web arayuzunden yonetmeyi saglar.

**Rancher, birden fazla Kubernetes cluster'ini tek bir arayuzden kurmayi, yonetmeyi ve yetkilendirmeyi saglayan cluster yonetim platformudur.**

## Ne Sagliyor?

- **Tek arayuzden coklu cluster yonetimi**: Farkli saglayicilarda (bare-metal, AWS, Azure, GCP) duran cluster'lar ayni ekranda toplanir. Her biri icin ayri kubeconfig tasimaya gerek kalmaz.
- **Merkezi kullanici ve yetki yonetimi**: Kullanicilar LDAP, Active Directory veya GitHub ile dogrulanir; RBAC kurallari tum cluster'lar icin tek yerden verilir.
- **Uygulama katalogu**: Helm chart'lari arayuzden kurulur. `values.yaml` duzenlemek icin terminale gecmek gerekmez.
- **Cluster kurma**: Yeni cluster'lari arayuzden olusturabilir, mevcut olanlari (Import) baglayabilirsin.
- **Gozlemlenebilirlik**: Node, pod ve kaynak kullanimi grafiklerle izlenir; Prometheus/Grafana entegrasyonu hazir gelir.
- **Ogrenme kolayligi**: Objeler arasi iliskiler gorsel olarak sunuldugu icin Kubernetes'e yeni baslayanlar icin iyi bir kesif araci olur.

## Rancher, k3s ve RKE Karistirilmamalidir

Ucu de ayni firmanin (SUSE) urunu oldugu icin bu isimler sik karistirilir:

- **k3s**: Hafif bir Kubernetes **dagitimidir**. Cluster'in kendisidir.
- **RKE / RKE2**: Kubernetes cluster'i kuran bir **kurulum aracidir**.
- **Rancher**: Cluster'lari **yoneten platformdur**. Bir cluster'in ustunde ya da tek basina bir container olarak calisir; cluster'in kendisi degildir.

## Kurulum: Docker ile (En Basit Yol)

Denemek veya tek bir sunucudan yonetmek icin en hizli yontem tek container calistirmaktir:

```bash
docker run -d --restart=unless-stopped \
  --name rancher \
  -p 80:80 -p 443:443 \
  --privileged \
  -v /opt/rancher:/var/lib/rancher \
  rancher/rancher:latest
```

- `--privileged`: Rancher kendi icinde bir k3s cluster'i ayaga kaldirdigi icin gereklidir.
- `-v /opt/rancher:/var/lib/rancher`: Verinin container disinda kalmasini saglar. **Bu satir atlanirsa container silindiginde tum ayarlar kaybolur.**
- Sertifika: Rancher kendinden imzali bir sertifika uretir, tarayici uyari verir. Bu beklenen bir durumdur.

Birkac dakika sonra `https://sunucu-adresi` adresinden arayuze erisilir.

## Kurulum: Kubernetes Uzerine (Helm)

Uretim ortaminda Rancher, var olan bir cluster'a Helm ile kurulur. Bu yontem yuksek erisilebilirlik (birden fazla replika) saglar.

Once **cert-manager** kurulur; Rancher sertifika yonetimi icin buna bagimlidir:

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager --create-namespace \
  --set crds.enabled=true
```

Ardindan Rancher:

```bash
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo update

helm upgrade --install rancher rancher-stable/rancher \
  --namespace cattle-system --create-namespace \
  --set hostname=rancher.ornek.com \
  --set bootstrapPassword=ilk-giris-parolasi \
  --set replicas=1
```

- `hostname`: Arayuze erisilecek alan adi. Sertifika ve Ingress bu isme gore uretilir, sonradan degistirilmesi zahmetlidir.
- `bootstrapPassword`: Ilk giristeki gecici parola.
- `replicas`: Varsayilan degeri `3`'tur. **Tek node'lu bir cluster'da `1` verilmezse podlar `Pending` durumunda kalir.**

Kurulumun bitmesini beklemek icin:

```bash
kubectl -n cattle-system rollout status deploy/rancher --timeout=300s
```

### Ingress Yoksa (Gateway API Kullaniliyorsa)

Rancher chart'i varsayilan olarak bir **Ingress** objesi olusturur. Cluster'da klasik bir Ingress controller yoksa (ornegin Traefik devre disi birakilip yerine Gateway API kullaniliyorsa) bu Ingress'i karsilayacak bir bilesen bulunmaz ve arayuze erisilemez.

Bu durumda Ingress kapatilir, TLS disarida sonlandirilir:

```bash
helm upgrade --install rancher rancher-stable/rancher \
  --namespace cattle-system --create-namespace \
  --set hostname=rancher.ornek.com \
  --set bootstrapPassword=ilk-giris-parolasi \
  --set replicas=1 \
  --set ingress.enabled=false \
  --set tls=external
```

Rancher artik HTTP dinler; sifreleme Gateway tarafinda yapilir. Yayinlamak icin bir `HTTPRoute` yazilir:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: rancher
  namespace: cattle-system
spec:
  parentRefs:
    - name: main-gw
      namespace: default
  hostnames:
    - rancher.ornek.com
  rules:
    - backendRefs:
        - name: rancher
          port: 80
```

HTTPRoute ile Gateway farkli namespace'lerde oldugundan, Gateway'in `allowedRoutes` ayari bu namespace'e izin veriyor olmalidir.

## Ilk Giris

Alan adi henuz yayinda degilse arayuze port yonlendirme ile erisilebilir:

```bash
kubectl -n cattle-system port-forward svc/rancher 8443:443
```

Tarayicidan `https://localhost:8443` acilir ve kurulumda verilen `bootstrapPassword` girilir. Parola unutulduysa cluster'dan okunabilir:

```bash
kubectl get secret --namespace cattle-system bootstrap-secret \
  -o go-template='{{.data.bootstrapPassword|base64decode}}{{"\n"}}'
```

Rancher ilk oturumda kalici parolayi belirletir ve `server-url` degerini sorar. Bu adres, yonetilen cluster'lardaki ajanlarin Rancher'a baglanmak icin kullanacagi adrestir; yanlis girilirse ajanlar baglanamaz.

## Cluster Ekleme

Var olan bir cluster'i baglamak icin arayuzde **Import Existing** secilir. Rancher bir `kubectl apply` komutu uretir; bu komut hedef cluster'da calistirilinca `cattle-cluster-agent` kurulur ve cluster listeye duser.

Ajan, Rancher'a **disaridan iceri** baglanti kurar. Bu nedenle yonetilen cluster'in internete acik olmasi gerekmez; yalnizca Rancher'in adresine erisebiliyor olmasi yeterlidir.

## Kullanisli Komutlar

```bash
# Rancher pod'larinin durumu
kubectl -n cattle-system get pods

# Rancher loglari
kubectl -n cattle-system logs -l app=rancher --tail=100 -f

# Bootstrap parolasini okuma
kubectl get secret --namespace cattle-system bootstrap-secret \
  -o go-template='{{.data.bootstrapPassword|base64decode}}{{"\n"}}'

# Kurulumda kullanilan degerleri gorme
helm get values rancher -n cattle-system

# Surum yukseltme
helm repo update
helm upgrade rancher rancher-stable/rancher -n cattle-system --reuse-values

# Docker ile kurulduysa log ve yeniden baslatma
docker logs -f rancher
docker restart rancher
```
