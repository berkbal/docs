# Pod

Podlar kubernetes'in en kucuk objesidir. Icerisinde bir veya birden fazla container barindirabilir. 

- Ayni pod icindeki uygulamalar ayni networku kullanir. Dolasiyila butun uygulamalar ayni ip adresine sahip olur.
- Pod icerisindeki containerlar ayni depolama birimine baglanir.

![Kubernetes Podlar](image-1.png)
Kaynak: Linuxfoundation

Podlar dogalari geregi kendi kendilerini onarma yetisine sahip degillerdir. Genelde daha buyuk olcekli kubernetes objeleri(controller) tarafindan olusturulurlar(Deployment, ReplicaSet, DaemonSet vs)

Asagidaki ornekte bir buyuk objeye bagimli olmadan bir pod nasil tanimlanir bunun ornegi mevcut:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    run: nginx-pod
spec:
  containers:
  - name: nginx-pod
    image: nginx:1.22.1
    ports:
    - containerPort: 80
```

Bu yapi genel olarak butun kubernetes objeleri icin gecerlidir.

- pod deploy etmek icin apiVersion alaninin `v1` olarak ayarlanmasi gerekmektedir.
- kind alani olusturulacak objenin turunu belirtir. `v1` apiden `Pod` isimli nesneyi olusturuyoruz.
- metadata'da ise bu objenin metadatasi bulunur. isim ve label kullanilarak diger nesneler ile etkilesim saglanabilir.(Ingres yonlendirmesi vs)

- spec alaninda ise pod'un icerisinde calismasi istenen containerin ozellikleri belirtilir. Birden fazla container `containers` basligi altina eklenebilir. Her bir containerin kendisine ozel olarak adı, dockerhub veya baska bir container registry üzerinden kullanacağı imajın ismi ve containerin **kullandığı** port buradan ayarlanır. Fakat burada belirtilen port disariya acilmaz. Disariya acmak icin `service` isimli k8s objesi gereklidir.

