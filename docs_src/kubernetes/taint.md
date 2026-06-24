# Taint ve Toleration

Label'lar objeleri secmeye yararken, Taint'ler tam tersini yapar: bir node'a uygulanir ve o node'a pod schedule edilmesini **engeller**. Yani Taint, node'un "beni rahat birak, uygun olmayan podlari uzerime alma" demesidir.

Taint node tarafinda tanimlanir. Pod tarafinda ise bu engeli asmaya yarayan karsiligi **Toleration**'dir. Bir pod, ancak node'daki taint'e uygun bir toleration tasiyorsa o node'a yerlesebilir.

**Taint iter, Toleration podun bu itmeye ragmen yerlesmesine izin verir.**

## Ne Zaman Kullanilir?

- Belirli node'lari ozel is yukleri icin ayirmak (ornegin GPU'lu node'lari yalnizca makine ogrenmesi podlarina vermek).
- Control plane node'larina normal uygulama podlarinin gelmesini engellemek (kubeadm bunu varsayilan olarak yapar).
- Bakima alinan veya sorunlu node'lardan podlari uzak tutmak ya da tahliye etmek.

## Taint Yapisi

Bir taint `key=value:effect` formatinda tanimlanir. Asil belirleyici kisim `effect` alanidir; podun akibetini bu belirler.

| Effect | Anlami |
|--------|--------|
| `NoSchedule` | Uygun toleration'i olmayan yeni podlar bu node'a schedule edilmez. Halihazirda calisan podlara dokunulmaz. |
| `PreferNoSchedule` | Scheduler mumkun oldugunca bu node'dan kacinir, ama baska secenek yoksa yine de yerlestirebilir. "Yumusak" versiyondur. |
| `NoExecute` | Yeni podlar schedule edilmez; ayrica uygun toleration'i olmayan **mevcut podlar da node'dan tahliye edilir** (evict). |

## Node'a Taint Uygulamak

```bash
kubectl taint nodes node1 gpu=true:NoSchedule
```

Bu komut `node1`'e `gpu=true` taint'ini `NoSchedule` etkisiyle ekler. Artik `gpu=true` toleration'i tasimayan hicbir pod bu node'a yerlesemez.

Taint'i kaldirmak icin komutun sonuna `-` eklenir:

```bash
kubectl taint nodes node1 gpu=true:NoSchedule-
```

## Pod'a Toleration Eklemek

Pod, node'daki taint'e cevap verecek toleration'i `spec.tolerations` altinda tanimlar. Asagidaki pod yukaridaki `gpu=true:NoSchedule` taint'ini tolere eder:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
spec:
  containers:
  - name: cuda-app
    image: nvidia/cuda:12.0-base
  tolerations:
  - key: "gpu"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"
```

- `key` / `value` / `effect`: Node'daki taint ile **birebir eslesmelidir**, aksi halde toleration gecersiz kalir.
- `operator`: `Equal` (varsayilan) key ve value'nun eslesmesini ister. `Exists` ise value alanini yok sayar, sadece key'in varligina bakar.

`Exists` ile bir node'daki o key'e sahip tum taint'leri (value'su ne olursa olsun) tolere edebilirsiniz:

```yaml
  tolerations:
  - key: "gpu"
    operator: "Exists"
    effect: "NoSchedule"
```

## NoExecute ve tolerationSeconds

`NoExecute` etkisinde, toleration'a `tolerationSeconds` eklenirse pod node'da sonsuza kadar degil, belirtilen sure kadar kalir. Sure dolunca tahliye edilir. Genelde bir node `NotReady` duruma dustugunde podu hemen atmak yerine bir sure beklemek icin kullanilir.

```yaml
  tolerations:
  - key: "node.kubernetes.io/not-ready"
    operator: "Exists"
    effect: "NoExecute"
    tolerationSeconds: 300
```

**Not: Toleration bir podu o node'a zorla yerlestirmez, yalnizca yerlesmesine izin verir. Podu belirli bir node'a cekmek istiyorsaniz `nodeSelector` veya `nodeAffinity` kullanmalisiniz. Taint/Toleration "itme", affinity ise "cekme" mekanizmasidir.**

## Taint ve Label Farki

Ikisi de node'a key:value seklinde yazilir ama amaclari zittir:

| | Label | Taint |
|---|-------|-------|
| Amac | Secmek / cekmek | Itmek / uzak tutmak |
| Kullanan | `nodeSelector`, selector | `tolerations` |
| Etkisi | Pasiftir, kendiliginden bir sey yapmaz | Aktiftir, podu engeller/tahliye eder |

## Kullanisli Komutlar

```bash
# Bir node'a taint ekle
kubectl taint nodes node1 key=value:NoSchedule

# Taint'i kaldir
kubectl taint nodes node1 key=value:NoSchedule-

# Bir node'un taint'lerini gor
kubectl describe node node1 | grep -i taint

# Tum node'larin taint'lerini tek bakista listele
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
```
