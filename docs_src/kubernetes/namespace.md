# Namespace

Namespace, cluster içindeki kaynakları mantıksal olarak ayırmaya yarayan bir objedir. Amaci İzolasyon saglamaktir. Her namespace kendi içinde Pod, Service, ConfigMap, Secret gibi objeleri tutar. Farklı namespace’lerde aynı isimli objeler olabilir.

Kullanıcı ve servis hesaplarının erişim yetkilerini namespace bazında sinirlandirmak mumkun.

## Ornekler

```bash
# Yeni namespace oluştur
kubectl create namespace dev

# Belirli namespace’e bir pod deploy et
kubectl run nginx --image=nginx -n dev

# Namespace içindeki objeleri listele
kubectl get pods -n dev

# Namespace sil
kubectl delete namespace dev
```

### Kubectl ile namespace kullanma

```bash
kubectl get pods -n dev
```

### Default namespace'i degistirmek

```bash
kubectl config set-context --current --namespace=dev
```

Bu ayari yaptiktan sonra kullanilan butun komutlar dev isimli namespace'e uygulanacaktir.