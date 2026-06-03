# Gateway API Nedir?

Ingress, uzun sure Kubernetes'te HTTP/HTTPS trafigini yonetmenin standart yolu oldu fakat bazi sinirlamalari vardir. Ingress yalnizca HTTP/HTTPS odaklidir, gelismis yonlendirme ozellikleri (header bazli routing, trafik agirliklandirma vb.) icin standart bir yapi sunmaz ve bu eksiklikler her controller'in kendi annotation'lari ile doldurulur. Bu da tasinabilirligi (portability) bozar.

Gateway API, bu sorunlari cozmek icin gelistirilen yeni nesil bir networking standardidir. Ingress'in yerini almak uzere tasarlanmistir; daha esnek, daha guclu ve rol bazli (role-oriented) bir yapi sunar. HTTP disinda TCP, UDP, TLS gibi protokolleri de destekler.

**Not: Gateway API, Kubernetes'in cekirdek (core) parcasi degildir. CRD (Custom Resource Definition) olarak cluster'a ayrica kurulmalidir.**

## Rol Bazli Tasarim

Gateway API'nin en onemli farki, sorumluluklari farkli rollere ayirmasidir. Boylece cluster yoneticisi ile uygulama gelistiricisinin sorumluluk alanlari net bir sekilde ayrilir. Uc temel kaynak (resource) bu rollere karsilik gelir:

- **GatewayClass**: Altyapiyi saglayan ekip (infrastructure provider) tarafindan tanimlanir. Hangi controller'in kullanilacagini belirtir. Ingress'teki `IngressClass`'in karsiligidir.
- **Gateway**: Cluster yoneticisi (cluster operator) tarafindan tanimlanir. Trafigin cluster'a girdigi noktayi, dinlenecek portlari ve protokolleri belirler.
- **HTTPRoute (ve TCPRoute, GRPCRoute vb.)**: Uygulama gelistiricisi tarafindan tanimlanir. Trafigin hangi servise nasil yonlendirilecegini belirler.

Bu ayrim sayesinde bir gelistirici, altyapiya dokunmadan yalnizca kendi route kurallarini yonetebilir.

## GatewayClass

Kullanilacak controller'i tanimlar. Genellikle controller kurulumu ile birlikte hazir gelir.

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: example-gateway-class
spec:
  controllerName: example.com/gateway-controller
```

- `controllerName`: Bu GatewayClass'i isleyecek controller'in adi.

## Gateway

Trafigin cluster'a girdigi noktayi tanimlar. Hangi portun, hangi protokol ile dinlenecegini ve hangi route'larin bu Gateway'e baglanabilecegini belirler.

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: example-gateway
spec:
  gatewayClassName: example-gateway-class
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    allowedRoutes:
      namespaces:
        from: Same
```

- `gatewayClassName`: Bu Gateway'in hangi GatewayClass'i kullanacagi.
- `listeners`: Dinlenecek port ve protokol tanimlari.
- `allowedRoutes`: Bu Gateway'e hangi namespace'lerden route baglanabilecegini belirler (`Same`, `All`, `Selector`).

## HTTPRoute

Gelen trafigin nasil yonlendirilecegini belirler. Bir Gateway'e baglanir ve `host`, `path`, `header` gibi kriterlere gore eslesme yapar.

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: frontend-route
spec:
  parentRefs:
  - name: example-gateway
  hostnames:
  - "app.example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: frontend-svc
      port: 80
```

- `parentRefs`: Bu route'un baglanacagi Gateway.
- `hostnames`: Kuralin gecerli oldugu domainler.
- `matches`: Eslesme kriterleri (path, header, method vb.).
- `backendRefs`: Trafigin yonlendirilecegi hedef service'ler.

## Trafik Agirliklandirma (Traffic Splitting)

Gateway API'nin guclu yanlarindan biri, trafigi birden fazla servise belirli oranlarda dagitabilmesidir. Bu ozellik canary deployment veya A/B testing icin idealdir. Ingress'te bu islem ancak controller'a ozel annotation'lar ile yapilabilirken, Gateway API'de standart bir alandir.

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: canary-route
spec:
  parentRefs:
  - name: example-gateway
  rules:
  - backendRefs:
    - name: app-v1
      port: 80
      weight: 90
    - name: app-v2
      port: 80
      weight: 10
```

- `weight`: Trafigin yuzde kaclik kismi bu backend'e yonlendirilecek. Yukaridaki ornekte trafigin %90'i `app-v1`'e, %10'u `app-v2`'ye gider.

## Ingress ile Karsilastirma

| Ozellik | Ingress | Gateway API |
| --- | --- | --- |
| Protokol destegi | HTTP/HTTPS | HTTP, HTTPS, TCP, UDP, TLS, gRPC |
| Rol ayrimi | Yok | Var (GatewayClass / Gateway / Route) |
| Gelismis routing | Annotation ile | Standart alanlarla |
| Trafik agirliklandirma | Standart degil | Standart |
| Cekirdek parcasi mi? | Evet | Hayir (CRD olarak kurulur) |

**Not: Gateway API, Ingress'i tamamen ortadan kaldirmaz; ancak Kubernetes toplulugu yeni projeler icin Gateway API'yi onermektedir. Ingress halen genis bir sekilde kullanilmaktadir.**

## Kullanisli Komutlar

```bash
kubectl get gatewayclass
kubectl get gateway
kubectl get httproute
kubectl describe gateway example-gateway
kubectl describe httproute frontend-route
```
