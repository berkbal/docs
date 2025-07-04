# **Linux LVM Disk Genişletme İşlemi**

**Başlamadan önce sanal makinenin yedeği mutlaka alınmalı.**

## Sanal Disk Boyutunu Artırma (Host Üzerinde)

Sanal makinenin ana disk dosyasının toplam boyutunu host (ana makine) üzerinden büyütülmesi gerekmektedir.

### 1. Sanal Makine Kapatılır:
Disk boyutunu güvenli artırmak için sanal makine kapalı olmalı.

```bash
virsh shutdown sanal_makine_adı
```

### 2. Sanal Disk Dosyasının Boyutunu Artırma

Sanal disk 10 GB büyütmek için `qemu-img resize` komutu host makinede çalıştırılır.

```bash
qemu-img resize /vm/disk/disk.qcow2 +10G
```

Bu komut diskin toplam boyutuna 10 GB ekler (örneğin 20G'den 30G'ye çıkarır).

-----

### 1. Disk Bölümlerini Düzenleme (Sanal Makine İçinde)

Sanal makineyi başlatıp içindeki partition tablosunun düzenlenmesi gerekmektedir. `qemu-img resize` ile eklenen 10 GB'lık alan şu an "boş" durumda. Kök bölüm (`/dev/vda1`) ile bu boş alan arasında `vda2` ve `vda5` gibi başka bölümler varsa bunlar kaldırılıp `vda1` genişletilir.

### 1.  Sanal Makineyi Başlatma

Host üzerinden sanal makine başlatılır.

 ```bash
virsh start sanal_makine_adı
```

### 2.  lsblk ile Disk Alanı Doğrulanır

Sanal makine içine girince `lsblk` komutu çalıştırılır. `vda` diskinin yeni boyutu (30G) doğrulanır. Eski bölümler hala görünmeli. Örnek çıktı:

```bash
    root@python:~# lsblk
    NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
    sr0     11:0    1 1024M  0 rom  
    vda    254:0    0   30G  0 disk 
    ├─vda1 254:1    0   19G  0 part /
    ├─vda2 254:2    0    1K  0 part 
    └─vda5 254:5    0  975M  0 part [SWAP]
```

### 3. Swap Alanını Devre Dışı Bırakma

Sistemde swap alanı olarak kullanılan bir bölüm varsa (örneğin `/dev/vda5`), `fdisk` işlemleri öncesinde devre dışı bırakılmalı. Diski sağa doğru genişletileceği için sağ tarafının boş olması önemli. Sonrasında disk bölümü yerine `swapfile` (takas dosyası) kullanılabilir.

    ```bash
    swapoff SWAP-ALANININ-BULUNDUGU-PARTITION
    # Örneğin: swapoff /dev/vda5
    ```

Swap'ın devre dışı kaldığı `free -h` komutuyla teyit edilir.

### 4. Disk Bölümlerini Silme ve Yeniden Oluşturma 

`fdisk` aracını kullanarak disk üzerindeki eski bölümler (`vda1`, `vda2`, `vda5`) silinir. `vda1` bölümü tüm diski kaplayacak şekilde yeniden oluşturulur. Böylece diskin başındaki veriler korunur. Sonundaki yeni alan da `vda1`'e dahil edilir.

```bash
fdisk /dev/vda
```

`fdisk` komut isteminde şunlar yapılır. Örnek çıktı aşağıdaki gibidir:
```
    root@python:~# fdisk /dev/vda

    Welcome to fdisk (util-linux 2.38.1).
    Changes will remain in memory only, until you decide to write them.
    Be careful before using the write command.

    This disk is currently in use - repartitioning is probably a bad idea.
    It's recommended to umount all file systems, and swapoff all swap
    partitions on this disk.


    Command (m for help): p

    Disk /dev/vda: 30 GiB, 32212254720 bytes, 62914560 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: dos
    Disk identifier: 0x4d8a8227

    Device     Boot    Start      End  Sectors  Size Id Type
    /dev/vda1  * 2048 39942143 39940096   19G 83 Linux
    /dev/vda2       39944190 41940991  1996802  975M  5 Extended
    /dev/vda5       39944192 41940991  1996800  975M 82 Linux swap / Solaris

    Command (m for help): d
    Partition number (1,2,5, default 5): 5

    Partition 5 has been deleted.

    Command (m for help): d
    Partition number (1,2, default 2): 2

    Partition 2 has been deleted.

    Command (m for help): d
    Selected partition 1
    Partition 1 has been deleted.

    Command (m for help): n
    Partition type
       p   primary (0 primary, 0 extended, 4 free)
       e   extended (container for logical partitions)
    Select (default p): p
    Partition number (1-4, default 1): 1
    First sector (2048-62914559, default 2048): 
    Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-62914559, default 62914559): 

    Created a new partition 1 of type 'Linux' and of size 30 GiB.
    Partition #1 contains a ext4 signature.

    Do you want to remove the signature? [Y]es/[N]o: no ((YES DENIRSE BUTUN VERILER SILINIR. NO DENMESI GEREKMEKTEDIR.))

    Command (m for help): p

    Disk /dev/vda: 30 GiB, 32212254720 bytes, 62914560 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: dos
    Disk identifier: 0x4d8a8227

    Device     Boot Start      End  Sectors Size Id Type
    /dev/vda1        2048 62914559 62912512  30G 83 Linux

    Command (m for help): w
    The partition table has been altered.
    Syncing disks.
```

-----

### 3. Sistemi Yeniden Başlatma

`fdisk`'te yapılan disk bölümleme tablosu değişikliklerinin işletim sistemi tarafından algılanması için sanal makine yeniden başlatılır.

```bash
sudo reboot
```

Sanal makine yeniden başlatılıp tekrar oturum açıldıktan sonra bir sonraki adıma geçilebilir.

-----

### **4. Dosya Sistemini Genişletme (Sanal Makine İçinde)**

Disk bölümü (`/dev/vda1`) fiziksel olarak genişlese de, üzerindeki dosya sistemi (genelde `ext4`) bu yeni boyutu henüz kullanmaz. Şimdi dosya sistemi de bölümün tamamını kaplayacak şekilde büyütülür.

### 1.  Disk Bölümü Boyutunu Doğrulama

Sanal makine içinde `lsblk` komutu çalıştırılır. `vda1` bölümünün yeni boyutu (30G) teyit edilir. Örnek çıktı aşağıdaki gibidir:

```bash
root@python:~# lsblk
    NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
    sr0     11:0    1 1024M  0 rom  
    vda    254:0    0   30G  0 disk 
    └─vda1 254:1    0   30G  0 part /
```

### 2. Dosya Sistemini Genişletme

Root dizinin (`/`) bağlı olduğu `/dev/vda1` bölümündeki `ext4` dosya sistemi genişletmek için `resize2fs` komutu kullanılır:

```bash
resize2fs /dev/vda1
```

Bu komut dosya sistemini otomatik olarak bölümün tamamını kaplayacak şekilde genişletir.

### 3. Genişletmeyi Doğrulama

İşlem bitince `df -h` komutu tekrar çalıştırılır. `/dev/vda1`'in boyutunun **30G**'ye yaklaştığı ve boş alanın arttığı görülür.

```bash
df -h
```