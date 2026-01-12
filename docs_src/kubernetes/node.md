# Node

Nodelar k8s clusterlari icerisinde bulunan fiziksel veya sanal kaynaklardir. Deploy edilen uygulamalar eklenen nodelar uzerinde calisir. Iki farkli node turu vardir: Control-plane ve worker node. Tipik bir k8s clusteri 1 adet control plane ve birden fazla worker node icerir. Yuksek erisilebilirlik icin genelde 3 veya daha fazla control plane node yapilandirilmasi onerilir.

Her worker node kubelet ve kube-proxy yardimiyla yonetilir ve icerisinde bir adet container runtime barindirir (genelde containerd). Runtime, nodelar uzerindeki container haline getirilmis uygulamalari calistirir. Kubelet container'larin yasam dongusunu yonetirken, kube-proxy ag trafigini yonlendirir.

## Kubelet Tarafindan Gerceklesen Islemler:

- Containerlari calistirmak
- Containerlarin ve node'un calisir durumda olup olmadigini kontrol etmek
- API sunucusuna olusan gelismeleri bildirmek

## Kube-Proxy Tarafindan Gerceklesen Islemler:

- Containerlara giden ag trafigini yonetmek
- Service'lerin ag kurallarini yapilandirmak