# Ingress Nedir?

Service objesi ile uygulamalarimizi `NodePort` veya `LoadBalancer` tipiyle disariya acabiliriz fakat bu yontemlerin sinirlari vardir. Her servis icin ayri bir port veya ayri bir load balancer ip adresi gerekir. Cok sayida uygulamayi disariya acmak istedigimizde bu yapi yonetilemez hale gelir.

Ingress, cluster disindan gelen HTTP ve HTTPS trafigini cluster icindeki servislere yonlendiren bir kurallar kumesidir. Tek bir giris noktasi uzerinden, gelen istegin `host` veya `path` bilgisine gore farkli servislere trafik dagitir. Bir nevi Layer 7 (application layer) reverse proxy gorevi gorur.

**Ingress, tek basina calismaz. Kurallari uygulayacak bir Ingress Controller'a ihtiyac duyar.**

## Ingress Controller

Ingress objesi sadece bir kural tanimidir; trafigi gercekte yonlendiren yapi Ingress Controller'dir. Controller, cluster icinde calisan ve API Server'i izleyerek Ingress kurallarini okuyup uygulayan bir uygulamadir (genellikle bir reverse proxy).

Kubernetes varsayilan olarak bir Ingress Controller ile gelmez; cluster'a ayrica kurulmalidir. Yaygin kullanilanlar:

- **ingress-nginx** (Nginx tabanli, en yaygin olani)
- **Traefik**
- **HAProxy**

**Not: Eger cluster'da kurulu bir Ingress Controller yoksa, olusturulan Ingress objesi hicbir ise yaramaz; trafik yonlendirilmez.**

## Ingress Calisma Mantigi

Trafik su sirayla ilerler:

1. Kullanici disaridan bir istek yapar (ornegin `app.example.com`).
2. Istek Ingress Controller'a ulasir (genellikle controller bir LoadBalancer veya NodePort service uzerinden disariya acilmistir).
3. Controller, gelen istegin `host` ve `path` bilgisine bakar.
4. Tanimli Ingress kurallarina gore istegi dogru ClusterIP service'e yonlendirir.
5. Service ise istegi arkasindaki Pod'lara iletir.

## Temel Ingress Tanimi

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: frontend-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-svc
            port:
              number: 80
```

- `ingressClassName`: Bu kurali hangi Ingress Controller'in isleyecegini belirtir.
- `rules`: Yonlendirme kurallarinin listesi.
- `host`: Hangi domain icin bu kuralin gecerli oldugunu belirtir.
- `path` ve `pathType`: Istegin URL yoluna gore eslesme yapilir.
- `backend.service`: Trafigin yonlendirilecegi hedef service ve port.

### pathType Degerleri

- **Prefix**: Belirtilen yol ile baslayan tum istekleri eslestirir (`/app` -> `/app`, `/app/x`).
- **Exact**: Yalnizca birebir ayni yolu eslestirir.
- **ImplementationSpecific**: Eslesme davranisi kullanilan Ingress Controller'a birakilir.

## Name Based Virtual Hosting

Tek bir ip adresi uzerinden birden fazla domain'i farkli servislere yonlendirebiliriz. Gelen istegin `host` basligina gore yonlendirme yapilir.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: virtual-hosting
spec:
  ingressClassName: nginx
  rules:
  - host: app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-svc
            port:
              number: 80
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-svc
            port:
              number: 80
```

## Fanout (Path Based Routing)

Ayni host uzerinde gelen istekleri, URL yoluna gore farkli servislere dagitabiliriz.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: fanout-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: example.com
    http:
      paths:
      - path: /app
        pathType: Prefix
        backend:
          service:
            name: app-svc
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-svc
            port:
              number: 80
```

## TLS ile Sifreleme

Ingress, HTTPS trafigini sonlandirabilir (TLS termination). Sertifika ve key bilgileri bir `Secret` icinde tutulur ve Ingress tanimina baglanir.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-ingress
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - app.example.com
    secretName: app-tls-secret
  rules:
  - host: app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-svc
            port:
              number: 80
```

- `tls.hosts`: Sertifikanin gecerli oldugu domainler.
- `tls.secretName`: TLS sertifikasi ve key'ini barindiran Secret objesinin adi. Bu Secret `kubernetes.io/tls` tipinde olmalidir.

## IngressClass

Bir cluster'da birden fazla Ingress Controller calisabilir. `IngressClass` objesi, hangi controller'in hangi Ingress'leri yonetecegini belirler. Ingress tanimindaki `ingressClassName` alani bu objeye referans verir.

```yaml
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: nginx
spec:
  controller: k8s.io/ingress-nginx
```

**Not: Bir IngressClass'i varsayilan yapmak icin `ingressclass.kubernetes.io/is-default-class: "true"` annotation'i kullanilir. Boylece `ingressClassName` belirtilmeyen Ingress'ler bu controller'a atanir.**

## Kullanisli Komutlar

```bash
kubectl get ingress
kubectl describe ingress frontend-ingress
kubectl get ingressclass
kubectl create ingress frontend-ingress --rule="app.example.com/*=frontend-svc:80"
```
