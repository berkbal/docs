# NFS Nedir?

NFS, "Network File System" kelimelerinin kısaltmasıdır. Adından da anlaşılacağı gibi, ağ üzerinden dosya paylaşımı sağlayan bir protokoldür (iletişim kuralı). Yani bu bir program ya da bir işletim sistemi değil, iki bilgisayarın birbiriyle dosya paylaşırken konuşmak için kullandığı bir dildir.

Temel amacı, bir bilgisayardaki dosyaların, ağa bağlı başka bir bilgisayar tarafından sanki kendi yerel diskiymiş gibi erişilebilir olmasını sağlamaktır. Bu sayede bir sunucuda merkezi bir depolama alanı oluşturup, birden fazla istemcinin (istemci) bu alandaki dosyalara erişmesini, okumasını, yazmasını ve düzenlemesi sağlanabilir.

## NFS Kurulumu

## Host Sunucuda Yapılacak İşlemler

### NFS'in kurulacağı sunucuda gerekli kurulumlar yapılır.

```bash
# Gerekli paketi kurma
sudo apt update
sudo apt install nfs-kernel-server -y
```

### Paylaşım yapılacak dizini oluşturup ayarlamaların yapılması:

**Dosya izinleri duruma ve kuruluma göre değişiklik göstermelidir. Mutlaka düzenkleyin.**

```bash
sudo mkdir -p /var/nfs/data
sudo chown nobody:nogroup /var/nfs/data
sudo chmod 777 /var/nfs/data
```

`vim /etc/exports` dosyasının içine:

- Duruma göre `no_root_squash` ayarı da yetki olarak eklenebilir fakat güvenlik riskleri içermektedir.
- 192.168.1.0/24 yerine spesifik bağlanması istenen sunucuların ip adrselerinin eklenmesi önerilir.

```bash
/var/nfs/data    192.168.1.0/24(rw,sync,no_subtree_check)
```

### NFS Sisteminin yeniden Başlatılması

```bash
systemctl restart nfs-kernel-server
```

## 2049 ve 111 portlarına erişim izni gerekmektedir. Sadece bağlanması beklenen ip adreslerine izin verilmersi önerilir.

## Client Tarafında Yapılacak İşlemler

## Gerekli Paketlerin Kurulması

```bash
apt update
apt install nfs-common -y
```

## Bağlantı İçin Dizin Oluşturulması

Dizinin ismi önemli değil. 

```bash
mkdir -p /mnt/k8s_storage
```

## NFS ile Uzaktaki Dizinin Mount Edilmesi

```bash
mount 192.168.1.X:/var/nfs/data /mnt/k8s_storage
```

## Otomatik Mount Edilmesi İçin /etc/fstab/ Dosyasının Düzenlenmesi

`vim /etc/fstab`

```bash
192.168.1.X:/var/nfs/data /mnt/k8s_storage nfs defaults 0 0
```