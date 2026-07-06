# NetworkPolicy Nedir?

Kubernetes'te varsayilan olarak cluster icindeki **butun podlar birbiriyle serbestce konusabilir**. Hangi namespace'te olursa olsun bir pod, baska bir podun IP adresini ve portunu biliyorsa ona istek atabilir. Bu "duz ag" (flat network) modeli baslangicta pratiktir ama guvenlik acisindan risklidir: ele gecirilen tek bir pod, tum cluster'daki servislere ulasabilir hale gelir.

NetworkPolicy, bu serbest trafigi kisitlamak icin kullanilan objedir. Podlar arasindaki (ve podlarla dis dunya arasindaki) trafige kural koyar; hangi kaynaktan gelen trafige izin verilecegini, hangi hedefe cikis yapilabilecegini belirler.

**NetworkPolicy, podlar seviyesinde calisan bir guvenlik duvari (firewall) gibidir; label'lara gore hangi trafige izin verilecegini tanimlar.**

## Onemli: CNI Gereksinimi

NetworkPolicy objesini olusturmak tek basina yeterli degildir. Bu kurallari fiilen uygulayan, cluster'da kullanilan **CNI (ag eklentisi)**'dir. Calico, Cilium ve Weave gibi eklentiler NetworkPolicy'yi destekler. Ancak yaygin kullanilan bazi basit eklentiler (ornegin varsayilan Flannel) bunu desteklemez.

***Not: NetworkPolicy destegi olmayan bir CNI kullaniyorsaniz, olusturdugunuz policy objeleri sessizce hicbir sey yapmaz. Obje `kubectl get` ile gorunur ama trafik hicbir sekilde kisitlanmaz. Kurallarin gercekten uygulandigini test etmeden guvenli oldugunuzu varsaymayin.***

## Varsayilan Davranis: Allow

Bir pod hicbir NetworkPolicy tarafindan secilmediginde, o pod icin tum trafik aciktir (allow all). Yani NetworkPolicy olusturana kadar hersey serbesttir.

Ama bir podu secen **en az bir** NetworkPolicy olustugu anda kural degisir: artik o pod icin **yalnizca policy'de acikca izin verilen trafik gecerli olur**, geri kalan her sey engellenir. Bu mantik NetworkPolicy'nin en cok karistirilan noktasidir:

- Policy yoksa: her sey serbest.
- Bir podu secen policy varsa: o policy'nin izin verdigi disindaki her sey kapali.

Yani NetworkPolicy bir kez devreye girdiginde "izin verilenler listesi" (whitelist) gibi calisir.

## Ingress ve Egress Farki

Bir NetworkPolicy iki yonde trafigi kontrol eder. Bu iki kavram NetworkPolicy'nin kalbidir:

| Yon | Anlami | Kimin bakis acisiyla? |
|-----|--------|------------------------|
| **Ingress** | Pod'a **gelen** (inbound) trafik | Policy'nin sectigi pod hedeftir; "bana kim baglanabilir?" |
| **Egress** | Pod'dan **cikan** (outbound) trafik | Policy'nin sectigi pod kaynaktir; "ben nereye baglanabilirim?" |

Onemli olan bakis acisidir: her ikisi de **her zaman policy'nin sectigi pod'un** perspektifinden tanimlanir.

- Bir web sunucusuna "sadece frontend podlari 8080 portundan baglanabilsin" demek istiyorsan → bu bir **ingress** kuralidir (web sunucusuna gelen trafik).
- Bir uygulamanin "sadece veritabanina ve DNS'e cikabilmesi, baska hicbir yere gidememesi" istiyorsan → bu bir **egress** kuralidir (uygulamadan cikan trafik).

Cogu senaryoda once **ingress** kurallari yazilir, cunku asil amac genellikle bir servise kimlerin ulasabilecegini sinirlamaktir.

## Policy Yapisi

Bir NetworkPolicy uc ana parcadan olusur:

- `podSelector`: Bu policy'nin **hangi podlara** uygulanacagini secer. Bos birakilirsa (`{}`) namespace'teki tum podlari secer.
- `policyTypes`: Bu policy'nin `Ingress`, `Egress` veya her ikisini birden kontrol ettigini belirtir.
- `ingress` / `egress`: Izin verilen trafik kurallarinin listesi (`from` / `to` ve `ports`).

## Ornek 1: Belirli Bir Porta Gelen Trafige Izin Vermek

En sik ihtiyac duyulan senaryo: bir container'in belirli bir portuna, yalnizca belirli podlardan gelen trafige izin vermek. Asagidaki ornek, `app: web` etiketli podlarin **8080 portuna**, yalnizca `app: frontend` etiketli podlardan gelen trafige izin verir. Baska her yerden gelen trafik engellenir.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: web-ingress-izni
  namespace: dev
spec:
  podSelector:
    matchLabels:
      app: web          # Bu kural app=web podlarina uygulanir (hedef)
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: frontend   # Sadece app=frontend podlarindan
      ports:
        - protocol: TCP
          port: 8080          # Sadece 8080/TCP portuna
```

Bu policy devreye girdiginde:

- `app: frontend` podlari → `app: web` podlarinin 8080 portuna **erisebilir**.
- Baska bir pod (ornegin `app: test`) → `app: web` podlarina **erisemez**.
- `app: frontend` bile olsa, 8080 disindaki bir porta (ornegin 3000) **erisemez**.

***Not: Buradaki `port`, container'in dinledigi porttur (yani pod'un `containerPort` degeri), Service portu degildir. NetworkPolicy podlar seviyesinde calisir; Service'in `port`/`targetPort` esleme mantigina karismaz.***

Birden fazla porta izin vermek istersen `ports` listesine ekleme yaparsin:

```yaml
      ports:
        - protocol: TCP
          port: 8080
        - protocol: TCP
          port: 8443
```

## Ornek 2: Her Seyi Engelle (Default Deny)

Guvenli bir baslangic noktasi genellikle "once her seyi kapat, sonra ihtiyac oldukca ac" yaklasimidir. Asagidaki policy, namespace'teki tum podlara gelen trafigi engeller:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: dev
spec:
  podSelector: {}        # Bos selector = namespace'teki TUM podlar
  policyTypes:
    - Ingress
  # ingress kurali yok = hicbir gelen trafige izin yok
```

`podSelector: {}` tum podlari secer, `ingress` altinda hicbir kural olmadigi icin de hicbir gelen trafik gecemez. Bu policy'yi olusturduktan sonra, yukaridaki Ornek 1 gibi policy'ler ekleyerek yalnizca ihtiyac duyulan trafigi tek tek acarsin. Ayni policy'ler **birbirinin uzerine eklenir** (additive); biri engelleyip digeri acmaz, izin verilenlerin birlesimi gecerli olur.

## Ornek 3: Egress ile Cikis Trafigini Kisitlamak

Asagidaki ornek, `app: web` podlarinin **sadece** `app: db` podlarina 5432 portundan cikis yapmasina izin verir. Ayrica DNS calismasi icin 53 portuna izin eklenmistir (aksi halde pod isim cozumlemesi yapamaz):

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: web-egress-izni
  namespace: dev
spec:
  podSelector:
    matchLabels:
      app: web
  policyTypes:
    - Egress
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: db
      ports:
        - protocol: TCP
          port: 5432
    - to: []                # Tum hedefler, ama sadece asagidaki portlar
      ports:
        - protocol: UDP
          port: 53
        - protocol: TCP
          port: 53
```

***Not: Egress kisitlarken DNS (53/UDP ve 53/TCP) icin izin vermeyi unutmak cok yaygin bir hatadir. Egress kapatildiginda pod, kube-dns/CoreDNS'e ulasamaz ve `nslookup`/servis isimleri calismaz. Bir servise `db.dev.svc.cluster.local` gibi isimle baglaniyorsan once DNS'in acik oldugundan emin ol.***

## from / to Secim Yontemleri

`from` (ingress) ve `to` (egress) altinda kaynagi/hedefi uc farkli sekilde secebilirsin:

- **podSelector**: Ayni namespace icindeki label'a uyan podlari secer.
- **namespaceSelector**: Belirli label'a sahip namespace'lerdeki podlari secer (namespace'ler arasi trafik icin).
- **ipBlock**: Cluster disindaki IP araliklarini secer (CIDR ile). Dis dunyaya/dis dunyadan trafik icin.

```yaml
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              ekip: backend
        - ipBlock:
            cidr: 10.0.0.0/16
            except:
              - 10.0.5.0/24
```

***Dikkat: Bir `from` elemaninda `podSelector` ve `namespaceSelector` ayni tire (`-`) altinda **birlikte** yazilirsa "VE" (AND) mantigi calisir: "su namespace'teki, su label'a sahip podlar". Ayri tirelerle yazilirsa "VEYA" (OR) olur. Bu ince fark, cogu NetworkPolicy hatasinin kaynagidir.***

## Kullanisli Komutlar

```bash
# Policy'leri listele
kubectl get networkpolicy -n dev
kubectl get netpol -n dev            # kisa adi

# Detayli inceleme (hangi podlari sectigini ve kurallari gorur)
kubectl describe netpol web-ingress-izni -n dev

# Bir podun hangi label'lara sahip oldugunu gor (selector'lar bununla eslesir)
kubectl get pods -n dev --show-labels

# Trafigi hizlica test etmek icin gecici bir pod acip baglanti dene
kubectl run test --rm -it --image=nicolaka/netshoot -n dev -- /bin/bash
# iceride:  curl web:8080   veya   nc -zv web 8080
```

***Not: NetworkPolicy'ler yalnizca yeni baglantilari kontrol eder ve TCP/UDP/SCTP seviyesinde calisir; HTTP yolu (path) veya metod gibi katman-7 detaylarina bakmaz. URL bazinda yetkilendirme istiyorsan bir service mesh (ornegin Istio, Cilium) veya Ingress seviyesinde kural kullanman gerekir.***
