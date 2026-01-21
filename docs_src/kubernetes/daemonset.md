# DaemonSet

DaemonSet, Kubernetes kümesindeki her bir Node (sunucu) üzerinde, belirli bir Pod'un tek bir kopyasının çalışmasını garanti eden bir objedir.

Genellikle uygulamanın kendisi değil; log toplama, ağ yönetimi (network) veya sistem izleme (monitoring) gibi altyapı işleri için kullanılır.

Pod'ların dışında çalışır. Diğer podların yanında başka bir pod olarak bulunur.

Örnek DaemonSet tanımı:

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd-agent
  namespace: default
  labels:
    k8s-app: fluentd-agent
spec:
  selector:
    matchLabels:
      k8s-app: fluentd-agent
  template:
    metadata:
      labels:
        k8s-app: fluentd-agent
    spec:
      containers:
      - name: fluentd
        image: quay.io/fluentd_elasticsearch/fluentd:v4.5.2
```