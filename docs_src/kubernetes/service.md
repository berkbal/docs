# Service Nedir?

Kubernetes'in amaci uygulamalari mikro servislere bolmek olmasina ragmen sistemi daha rahat yonetebilmek ve gerektiginde yuk dengelemek(load balancing) amaciyla mikro servisleri mantiksal olarak gruplamak gerekmektedir.

Kube-proxy ile birlikte calisir.

**Birden fazla pod halinde deploy edilmis bir uygulamayi ek bir dns kaydi ile erisilebilir kilmaya olanak saglar.**

## Uygulamalara Erisim

Bir uygulamaya erisebilmek icin uygulamalari deploy ettigimiz podlara erisilmelidir fakat podlarin yapisi geregi sabit bir ip adresleri yoktur. Ayrica gereksinimlere gore podlar en cok kapatilan veya hata alarak kendi kendine kapanan yapilardir. Bu sebepten dolayi uygulamaya erisim saglarken podlarin ip adreslerini kullanamayiz.

![service-pod-yenileme](image-5.png)

Yukaridaki gorseldeki gibi bir durum yasandiginda podun ip adresi degisir ve bu ip adresini diger uygulamalar veya kullanicilar bilemez. Bu sorunu cozmek icin Kubernetes'de bulunan service objesini kullanabiliriz. Service objesi podlari mantiksal olarak gruplar ve bu podlara erisim icin bir police belirler. Bu gruplama Label ve Selector ile saglanir.

Ornek:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: frontend
  name: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend
    template:
      metadata:
        labels:
          app: frontend
      spec:
        containers:
        - image: frontend-application
        name: frontend-application
        ports:
        - containerPort: 5000 
```

Label ve selectorler key:value formatini kullanir.

![key:value orneklenmesi](image-6.png)

kaynak: linuxfoundation

Yukaridaki gorselde `app==frontend` ve `app==db` olarak iki farkli sekilde gruplandigi gozlemlenebilir. Bu sayede podlarad cikan sorunlardan sonra podlar yeniden basladiginda ip adresi degisimi oldugunda bile `service` objesi trafigi dogru yere yonlendirir.

Service objesi uygulamalari bir nevi disariya acmaya ve erisilebilir kilmaya yarar.

## Temel Service Tanimi

```bash
apiVersion: v1
kind: Service
metadata:
  name: frontend-svc
spec:
  selector:
    app: frontend
  ports:
  - protocol: TCP
    port: 80
    targetPort: 5000
```

Yukaridaki tanim en temel service tanimidir. Istege ve ihtiyaca gore daha komplike hale getirilebilir. Bu servis tanimi `app` degeri `frontend` olan objelere trafik yonlendirecektir. 

Service'lerin type'lari vardir. Bos biraktigimiz icin default type olan `ClusterIP` typei ile olusur.

***Not: Expose komutu ile bir deployment veya baska bir obje disariya acildiginda aslinda arkaplanda bir service tanimi olusur. Olusan bu service kendi taniminda otomatik olarak expose edilen objenin labelina baglanir.***

## Kube-Proxy

