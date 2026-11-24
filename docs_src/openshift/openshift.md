# Redhat OpenShift

## OpenShift Nedir?

Kubernetes tek basina bir konteyner yonetim cekirdegidir. Bir cluster'i production'a hazir hale getirmek icin uzerine bircok parca eklemek gerekir: disariya trafik acmak icin bir ingress controller, image'lari tutmak icin bir registry, metrik ve alarm icin bir monitoring stack, kullanici girisi icin bir kimlik dogrulama sistemi, cluster'i guncellemek icin bir yontem... Bunlarin her birini ayri ayri secmek, kurmak, birbirine uyumlu tutmak ve guncellemek ciddi bir is yukudur.

OpenShift, bu parcalari Kubernetes'in uzerine **hazir ve birbirine entegre sekilde** getiren bir platformdur. Yani "Kubernetes + etrafinda olmasi gereken her sey" diye dusunebiliriz.

**OpenShift, Red Hat'in gelistirdigi, Kubernetes tabanli, kurumsal kullanim icin paketlenmis bir konteyner platformudur.**

Burada onemli nokta sudur: OpenShift Kubernetes'in yerine gecen bir sey degildir, **Kubernetes'in kendisidir**. Altta ayni API Server, ayni etcd, ayni scheduler calisir. Pod, Deployment, Service gibi bildigimiz tum objeler aynen gecerlidir. OpenShift bunlarin uzerine kendi objelerini ve araclarini ekler.

## Kubernetes Uzerine Neler Ekler?

Saf Kubernetes'te asagidakilerin her birini kendimiz secip kurariz. OpenShift'te ise hepsi kurulumla birlikte gelir:

- **Isletim sistemi**: Kubernetes isletim sistemi secmez, node'lara istedigimiz Linux'u kurariz. OpenShift'te node'lar Red Hat Enterprise Linux CoreOS (RHCOS) uzerinde calisir. RHCOS degistirilemez (immutable) bir isletim sistemidir ve cluster tarafindan yonetilir. Control plane node'larinda RHCOS zorunludur.
- **Konteyner runtime**: Kubernetes'te containerd veya CRI-O arasinda secim yapariz. OpenShift'te CRI-O kullanilir.
- **Ag**: Kubernetes'te Calico, Flannel, Cilium gibi bir CNI eklentisini kendimiz kurariz. OpenShift'te varsayilan CNI eklentisi OVN-Kubernetes'tir.
- **Route**: Kubernetes'te Ingress objesinin calismasi icin ayrica bir ingress controller kurmak gerekir. OpenShift'te HAProxy tabanli bir router hazir gelir ve uygulamalar Route objesiyle disari acilir. Standart Ingress objesi de desteklenir.
- **Dahili image registry**: Kubernetes'te registry dissal bir hizmettir. OpenShift'te cluster icinde hazir bir image registry gelir.
- **Build ve ImageStream**: Kubernetes image uretmez, image'i disarida build edip registry'ye basariz. OpenShift'te kaynak koddan image uretmek (BuildConfig, Source-to-Image) ve image'lari takip etmek (ImageStream) icin kendi objeleri vardir.
- **Web console**: Kubernetes Dashboard ayrica kurulan ve sinirli bir aractir. OpenShift'te hem yoneticiler hem gelistiriciler icin kapsamli bir web arayuzu hazir gelir.
- **Kimlik dogrulama**: Kubernetes'in kendi kullanici sistemi yoktur, sertifika veya dissal bir OIDC saglayicisi kullaniriz. OpenShift'te dahili bir OAuth sunucusu gelir. HTPasswd, LDAP gibi kimlik saglayicilari buna baglanir ve kullanicilar `oc login` ile giris yapar.
- **Guvenlik varsayilanlari**: Kubernetes varsayilan olarak konteynerin image'da tanimli kullaniciyla (cogu zaman root) calismasina izin verir. OpenShift'te SecurityContextConstraints (SCC) ile pod'larin ne yapabilecegi kisitlanir. Varsayilan olarak konteynerler root olarak degil, project'e ayrilmis bir UID araligindan atanan bir kullanici ID'si ile calisir. Bu yuzden root ile calismaya alisik image'lar OpenShift'te sorun cikarabilir.
- **Monitoring**: Kubernetes'te Prometheus stack'i ayrica kurulur. OpenShift'te Prometheus ve Alertmanager tabanli monitoring stack'i kurulu gelir.
- **Operator'lar**: Kubernetes'te Operator'lar istege bagli bir kaliptir. OpenShift'te ise cluster'in kendi bilesenleri (router, registry, monitoring, DNS...) Operator'lar tarafindan yonetilir. Ek yazilimlar da OperatorHub uzerinden Operator olarak kurulur.
- **Guncelleme**: Kubernetes'te (ornegin kubeadm ile) control plane, node'lar ve isletim sistemi ayri ayri guncellenir. OpenShift'te cluster, Cluster Version Operator sayesinde isletim sistemi dahil tek bir islemle guncellenir.

## Kubernetes ile OpenShift Arasindaki Farklar

| Kubernetes | OpenShift | Aciklama |
|---|---|---|
| `kubectl` | `oc` | `oc`, `kubectl`'in tum komutlarini destekler. Ustune `oc login`, `oc new-app`, `oc project` gibi OpenShift'e ozgu komutlar ekler. |
| Namespace | Project | Project, ek ozellikleri olan bir namespace'tir. Her project arkada bir namespace olusturur. |
| Ingress | Route | Ikisi de desteklenir, OpenShift'te yaygin olan Route'tur. |
| Pod Security Admission | SCC | OpenShift'te pod guvenligi asil olarak SCC ile yonetilir. |
| Deployment | Deployment | Eskiden OpenShift'e ozgu DeploymentConfig kullanilirdi. 4.14 surumunde deprecated oldu, artik standart Deployment kullanilir. |
| Image tag'i | ImageStream | ImageStream, bir image'i takip eden ve degistiginde deployment'i tetikleyebilen bir objedir. |
| Kurulum (kubeadm vb.) | `openshift-install` | Cluster kurulumu ve guncellemesi platformun kendisi tarafindan yonetilir. |

## OpenShift Surumleri

- **OpenShift Container Platform (OCP)**: Kendi altyapimiza (bare metal, VMware, bulut) kurdugumuz, Red Hat destekli surum.
- **OKD**: OpenShift'in topluluk (upstream) surumu. Ucretsizdir, Red Hat destegi yoktur.
- **Yonetilen surumler**: Red Hat OpenShift Service on AWS (ROSA), Azure Red Hat OpenShift (ARO) ve OpenShift Dedicated. Cluster'i Red Hat ve bulut saglayici yonetir.
- **OpenShift Local**: Tek makinede calisan, deneme ve ogrenme amacli kucuk bir OpenShift cluster'i.
