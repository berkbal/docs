# Deployment

Deployment objesi podları ve ReplicaSet'leri dolaylı yoldan yöneten üst seviye bir objedir. Deployment tanımı ReplicaSet'i yönetir, ReplicaSet de podları yönetir. RollingUpdate ve Recreate güncelleme stratejilerini destekler.

### Örnek Deployment Tanımı


```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-deployment
  template:
    metadata:
      labels:
        app: nginx-deployment
    spec:
      containers:
      - name: nginx
        image: nginx:1.20.2
        ports:
        - containerPort: 80
```

apiVersion alanı ilk zorunlu alandır ve bağlanmak istediğimiz API sunucusu üzerindeki API uç noktasını (endpoint) belirtir; bu alan, tanımlanan nesne türü için mevcut bir sürümle eşleşmelidir. İkinci zorunlu alan, nesne türünü belirten kind alanıdır; bizim durumumuzda bu Deployment'tır ancak Pod, ReplicaSet, Namespace, Service vb. de olabilir. Üçüncü zorunlu alan olan metadata, nesnenin isim, notlar (annotations), etiketler (labels), ad alanları (namespaces) gibi temel bilgilerini tutar. Örneğimiz iki spec alanı göstermektedir: `spec` Deployment'ın özelliklerini, `spec.template.spec` ise oluşturulacak Pod'ların özelliklerini tanımlar.

Aşağıdaki komut ile bu tanımı `kubectl` ile generate edebiliriz.

```bash
kubectl create deployment nginx-deployment \
--image=nginx:1.20.2 --port=80 --replicas=3 \
--dry-run=client -o yaml > nginx-deploy.yaml
```