# Control Plane Node Bilesenleri

Control plane node'da asagidaki bilesenlere ek olarak container runtime, node agent (kubelet), proxy (kube-proxy), ve kisisel ihtiyaclara gore kurulan add-onlar calismaktadir.

## API Server:

Bir clusterin butun yonetim islemleri kube-apiserver uzerinde gerceklesir. RESTful bir sekilde call alir ve sistemdeki normal kullanicilar, yoneticiler ve developerlar tarafindan talepleri alip islem gerceklestirir. 

Bu islemleri gerceklestirirken clusterin `key:value`(etcd) durumunu uzerinden okur, islemi gerceklestirir ve son durumu tekrar `key:value` seklinde etcd'ye ekler.

## Scheduler:

kube-scheduler'in rolu deploy edilen objelerin hangi nodelarda calisacagina krar vermektir. `API SERVER` araciligi ile etcd uzerinden clusterdaki calisan nodelar icin kaynak kullanim verilerini, etiketleri vs goz onunde bulundurarak hangi node'a deploy edilecegini belirler. Sonrasinda da nodelar icerisinde bulunan `kubelet`ler podlari deploy eder.

##  Controller Manager:

Deploy edilen uygulamalari duzenli olarak izleyerek calismasi istenen statede kalmasini saglar. Bir uygulamanin hangi kosullarda nasil calisacagini deploy ederken tanimlariz. Eger tanimlanan kosullar karsilanmazsa uygulamayi tekrar deploy eder/yeniden baslatir veya belli basli kosullar ile `state` eslesene kadar belirtilen islemleri tekrarlar.

## Key-Value Data Store(etcd):

`etcd` CNCF tarafinan yonetilen acik kaynakli bir projedir. Kubernetes clusterinin anlik olarak hangi durumda oldugunu saklamak/depolamak amaciyla kullanilir. Sadece `API SERVER` tarafindan erisilebilir ve master node uzerinden `etcdctl` adindaki komut satiri araci ile yonetilebilir. Ayrica istenirse ayri bir sekilde olusturulan bir etcd clusteri control plane node'a baglanarak yonetilebilir. Bu sayede etcd de `HA` haline getirilip daha saglam bir altyapi elde edilir. 

ConfigMap ve Secrets gibi k8s objeleri de etcd uzerinde saklanir.