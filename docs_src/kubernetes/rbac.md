# RBAC Nedir?

Bir cluster buyudukce, ona kimlerin ne yapabilecegini kontrol etmek kritik hale gelir. Bir gelistiricinin sadece kendi namespace'indeki pod'lari gorebilmesi, bir CI/CD servisinin yalnizca deployment guncelleyebilmesi ama secret'lari okuyamamasi gibi ihtiyaclar dogar. Bu yetkilendirmeyi her kullanici icin tek tek elle yonetmek hem zahmetli hem de hataya acik olur.

RBAC (Role-Based Access Control), bu sorunu cozerek **yetkileri rollere baglayan** bir yetkilendirme mekanizmasi sunar. Mantik basittir: bir rol "neyin yapilabilecegini" tanimlar, bir baglama (binding) ise bu rolu "kime verecegimizi" belirler.

**RBAC, cluster icinde kimin hangi kaynak uzerinde hangi islemi yapabilecegini tanimlayan yetkilendirme sistemidir.**

RBAC, API Server seviyesinde calisir. Bir istek geldiginde API Server once kullanicinin kim oldugunu dogrular (authentication), ardindan RBAC kurallarina bakarak bu istegin yetkili olup olmadigina karar verir (authorization).

## Temel Bilesenler

RBAC dort temel objeden olusur. Bunlari iki gruba ayirabiliriz:

- **Role / ClusterRole**: Hangi islemlerin yapilabilecegini tanimlar (yetki kumesi).
- **RoleBinding / ClusterRoleBinding**: Bu yetki kumesini bir kullaniciya, gruba veya servis hesabina baglar.

Aralarindaki fark ise kapsamdir (scope):

- **Role** ve **RoleBinding** namespace seviyesinde calisir. Yalnizca tanimlandiklari namespace icinde gecerlidir.
- **ClusterRole** ve **ClusterRoleBinding** ise cluster geneline yayilir. Tum namespace'leri ve namespace'e bagli olmayan kaynaklari (node, persistentvolume gibi) kapsar.

## Role

Role, belirli bir namespace icinde hangi kaynaklara hangi islemlerin yapilabilecegini tanimlayan objedir. Tek basina bir ise yaramaz; bir RoleBinding ile bir kullaniciya baglanana kadar hicbir etkisi yoktur.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: dev
  name: pod-okuyucu
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```

- `namespace`: Rolun gecerli olacagi namespace. Role objesi namespace'e bagimlidir.
- `rules`: Yetki kurallarinin listesi. Bir rolde birden fazla kural tanimlanabilir.
- `apiGroups`: Kaynagin ait oldugu API grubu. Core grup (pod, service, configmap vb.) icin bos string `""` kullanilir. Deployment gibi kaynaklar icin `"apps"` yazilir.
- `resources`: Kuralin uygulanacagi kaynak turleri (`pods`, `deployments`, `secrets` vb.).
- `verbs`: Bu kaynaklar uzerinde izin verilen islemler (`get`, `list`, `create` vb.).

Yukaridaki ornek, `dev` namespace'inde pod'lari okumaya (gor, izle, listele) izin verir ama silme veya olusturma yetkisi vermez.

### Verbs (Islemler)

`verbs` alani, kaynak uzerinde hangi islemlere izin verildigini belirler. En cok kullanilanlar:

- **get**: Tek bir kaynagi getirir.
- **list**: Kaynaklari listeler.
- **watch**: Kaynaklardaki degisiklikleri izler.
- **create**: Yeni kaynak olusturur.
- **update**: Var olan kaynagi gunceller.
- **patch**: Kaynagin bir kismini gunceller.
- **delete**: Kaynagi siler.

Bir kaynak uzerindeki tum islemlere izin vermek icin tek tek yazmak yerine `["*"]` kullanilabilir.

## RoleBinding

RoleBinding, bir Role'u (veya ClusterRole'u) bir oznelere (subject) baglar. Yani "su yetkiyi su kisiye ver" demektir. Baglama yapilmadan rolun hicbir etkisi olmaz.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-okuyucu-binding
  namespace: dev
subjects:
- kind: User
  name: berk
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-okuyucu
  apiGroup: rbac.authorization.k8s.io
```

- `subjects`: Yetkinin verilecegi oznelerin listesi. Bir kullanici (`User`), bir grup (`Group`) veya bir servis hesabi (`ServiceAccount`) olabilir.
- `roleRef`: Hangi rolun baglanacagini belirtir. `kind` alani `Role` veya `ClusterRole` olabilir.

Bu ornek, `pod-okuyucu` rolunu `berk` kullanicisina `dev` namespace'i icinde baglar. Artik `berk` kullanicisi sadece `dev` namespace'indeki pod'lari okuyabilir.

***Not: roleRef bir kez olusturulduktan sonra degistirilemez. Farkli bir rol baglamak isteniyorsa RoleBinding silinip yeniden olusturulmalidir.***

## Subjects (Ozneler)

RBAC'da yetki verilen uc tur ozne vardir:

- **User**: Insan kullanicilarini temsil eder. Kubernetes kullanicilari kendi icinde tutmaz; bunlar genellikle sertifikalar, OIDC veya harici bir kimlik saglayici uzerinden gelir.
- **Group**: Birden fazla kullaniciyi tek seferde yetkilendirmek icin kullanilan gruptur.
- **ServiceAccount**: Cluster icindeki uygulamalarin/pod'larin API Server ile konusurken kullandigi hesaptir. Insan degil, makine kimligidir.

## ClusterRole ve ClusterRoleBinding

Role namespace ile sinirlidir. Ancak bazi kaynaklar namespace'e bagli degildir (node, persistentvolume, namespace'in kendisi gibi) veya bir yetkinin tum namespace'lerde gecerli olmasi istenebilir. Bu durumlarda ClusterRole kullanilir.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-okuyucu
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "watch", "list"]
```

ClusterRole'un namespace alani yoktur; cunku cluster geneline aittir. Bu rolu bir ozneye baglamak icin ClusterRoleBinding kullanilir:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: node-okuyucu-binding
subjects:
- kind: User
  name: berk
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: node-okuyucu
  apiGroup: rbac.authorization.k8s.io
```

Bu baglama ile `berk` kullanicisi cluster'daki tum node'lari okuyabilir.

***Not: Bir ClusterRole, bir RoleBinding ile de baglanabilir. Bu sik kullanilan bir desendir: ortak bir yetki kumesi (ClusterRole olarak) bir kez tanimlanir, ardindan her namespace'te ayri RoleBinding'ler ile o namespace'e ozel olarak verilir. Boylece ayni rolu her namespace icin tekrar tekrar yazmaya gerek kalmaz.***

## ServiceAccount ile Kullanim

Cluster icinde calisan bir uygulamanin API Server ile konusmasi gerektiginde (ornegin pod'lari listeleyen bir operator), bu uygulamaya bir ServiceAccount uzerinden yetki verilir. Her namespace'te varsayilan olarak `default` adinda bir ServiceAccount bulunur, ancak guvenlik acisindan her uygulama icin ayri ve sinirli yetkili bir ServiceAccount olusturmak daha dogrudur.

Once bir ServiceAccount olusturulur:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: uygulama-sa
  namespace: dev
```

Ardindan bu ServiceAccount bir RoleBinding ile bir role baglanir:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: uygulama-sa-binding
  namespace: dev
subjects:
- kind: ServiceAccount
  name: uygulama-sa
  namespace: dev
roleRef:
  kind: Role
  name: pod-okuyucu
  apiGroup: rbac.authorization.k8s.io
```

Son olarak pod tanimi icinde bu ServiceAccount `serviceAccountName` alani ile belirtilir:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: uygulama-pod
  namespace: dev
spec:
  serviceAccountName: uygulama-sa
  containers:
  - name: uygulama
    image: nginx:1.22.1
```

Boylece pod icinde calisan uygulama, yalnizca `pod-okuyucu` rolunun verdigi yetkilerle (yani `dev` namespace'indeki pod'lari okumakla) sinirli kalir.

**Not: En az yetki prensibi (least privilege) RBAC'da temel kuraldir. Bir ozneye, isini yapmasi icin gereken minimum yetkiden fazlasini vermemek gerekir. Ozellikle ServiceAccount'lara genis yetki vermek, ele gecirilen bir pod'un tum cluster'i tehlikeye atmasina yol acabilir.**

## Kullanisli Komutlar

```bash
# Role ve binding'leri listele
kubectl get roles -n dev
kubectl get rolebindings -n dev
kubectl get clusterroles
kubectl get clusterrolebindings

# Detayli inceleme
kubectl describe role pod-okuyucu -n dev

# Bir kullanicinin/servis hesabinin bir islemi yapip yapamayacagini test et
kubectl auth can-i list pods -n dev
kubectl auth can-i delete pods -n dev --as=berk
kubectl auth can-i get nodes --as=system:serviceaccount:dev:uygulama-sa

# Hizlica role ve binding olusturmak
kubectl create role pod-okuyucu --verb=get,list,watch --resource=pods -n dev
kubectl create rolebinding pod-okuyucu-binding --role=pod-okuyucu --user=berk -n dev
```

***Not: `kubectl auth can-i` komutu, RBAC kurallarini fiilen denemeden test etmenin en pratik yoludur. `--as` parametresi ile baska bir kullanici veya servis hesabi gibi davranarak (impersonation) onlarin yetkilerini kontrol edebilirsiniz.***
