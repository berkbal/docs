# Worker Node

Worker node, deploy edilen uygulamalar icin calisma ortami saglar. Uygulamalar container'lar halinde podlar icerisinde calisir. **Scheduler tarafindan bir worker node'a atanan pod, o node'daki kubelet tarafindanc alistirilir.** Podlar, worker node'un CPU, bellek ve depolama kaynaklarini kullanir.

## Container Runtime:

CRI-O, containerd, docker, mirantis gibi bir container runtime worker nodelar uzerinde calisir. Genelde hafif ve guvenli olmasindan dolayi **containerd** tercih edilir. Uygulamalarin container halinde calismasi icin worker node'da bir adet container runtime bulunmasi gerekmektedir.

## Node Agent(Kubelet):

kubelet, her node üzerinde (control plane ve worker'lar) çalışan bir agent'tir ve control plane ile iletişim kurar. Pod tanımlarını öncelikle API Server'dan alır ve Pod ile ilişkili container'ları çalıştırmak için node üzerindeki container runtime ile etkileşime geçer. Ayrıca container'ları çalıştıran Pod'ların sağlığını ve kaynaklarını izler.

## Kube-Proxy

- kube-proxy, her node üzerinde (control plane ve worker'lar) çalışan bir network agent'tır ve node üzerindeki tüm network kurallarının dinamik güncellemelerinden ve bakımından sorumludur. Pod'ların network detaylarını soyutlar ve bağlantı isteklerini Pod'lar içindeki container'lara iletir. 

- Bir uygulamanın Pod backend'leri arasında TCP, UDP ve SCTP stream forwarding veya random forwarding işlemlerinden sorumludur ve kullanıcılar tarafından Service API objeleri üzerinden tanımlanan forwarding kurallarını uygular.

- kube-proxy node agent'ı, node'un iptables'ı ile birlikte çalışır. Iptables, Linux işletim sistemi için oluşturulmuş bir firewall aracıdır ve kullanıcılar tarafından aynı isimde bir CLI aracı ile yönetilebilir. Iptables aracı birçok Linux dağıtımında mevcuttur ve önceden yüklenmiş olarak gelir.
