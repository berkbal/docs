# OpenHPC Kurulum Dokümani

## Genel Hazirlik (Tüm Sunucularda Yapilacak)

### 1. Temiz openSUSE Leap 15.6 Kurulumu

Kurulum sirasinda dikkat edilecekler:

- **System Role**: Server
- **Partitioning**: LVM + ext4, swap 2GB yeterli
- **Network**: Kurulumda DHCP, sonra statik IP verilecek

### 2. Temel Paket Kurulumu

```bash
zypper refresh && zypper update
zypper install vim curl wget git net-tools
systemctl enable sshd --now
```

### 3. Hostname Ayarlama

Her sunucuda ilgili hostname atanir:

```bash
hostnamectl set-hostname master    # veya node01, node02
```
    
### 4. Hosts Dosyasi (Tüm Sunucularda Ayni)

`/etc/hosts` dosyasina asagidaki satirlar eklenir:

```
192.168.122.10  master
192.168.122.11  node01
192.168.122.12  node02
```

### 5. IP Adresi Sabitleme

openSUSE üzerinde `/etc/sysconfig/network/ifcfg-INTERFACE_ADI` dosyasi düzenlenir:

```
BOOTPROTO='static'
IPADDR='192.168.122.10'
NETMASK='255.255.255.0'
```

Gateway icin `/etc/sysconfig/network/routes` dosyasina:

```
default 192.168.122.1 - -
```

Degisiklikleri uygulamak icin:

```bash
wicked ifreload INTERFACE_ADI
```

### 6. AppArmor Kapatma

openSUSE'de SELinux yerine AppArmor bulunur. Lab ortami icin kapatilir:

```bash
systemctl disable apparmor --now
```

### 7. Firewall Kapatma

```bash
systemctl disable firewalld --now
```

---

## Master Node Üzerinde Yapilan Islemler

### 1. OpenHPC Reposu Ekleme

Resmi OpenHPC reposu eklenir. Asagidaki linklerden uyumlu olan kullanilir:

```bash
# v3.0 icin:
zypper install -y https://github.com/openhpc/ohpc/releases/download/v3.0.GA/ohpc-release-3-1.leap15.x86_64.rpm

# Eger yukaridaki link calismiyorsa repos.openhpc.community üzerinden:
zypper install -y http://repos.openhpc.community/OpenHPC/3/Leap_15/x86_64/ohpc-release-3-1.leap15.x86_64.rpm
```

> **Not:** GPG key hatasi alinirsa `--no-gpg-checks` parametresi kullanilabilir. Tavuk-yumurta problemi: key'i getiren RPM'in kendisini kurmak icin key gerekir.

### 2. OpenHPC Base Kurulumu

```bash
zypper install -y ohpc-base
```

### 3. Slurm Server Kurulumu

Bu komut slurmctld ve munge dahil tüm bagimliliklari kuracaktir:

```bash
zypper install -y ohpc-slurm-server
```

Kurulan servisler:

- **slurmctld**: Slurm controller daemon — is kuyruklarini ve node'lari yönetir
- **munge**: Node'lar arasi authentication saglayan daemon

### 4. Slurm Client Araclari Kurulumu

Master üzerinde de `sinfo`, `squeue` gibi komutlarin calisabilmesi icin:

```bash
zypper install -y slurm-ohpc
```

### 5. Munge Key Olusturma

Munge kurulumu sirasinda otomatik olarak key olusur. Dogrulamak icin:

```bash
ls -la /etc/munge/munge.key
```

Eger key yoksa manuel olusturulur:

```bash
mungekey --create
```

> **Not:** openSUSE'de `create-munge-key` komutu bulunmaz, `mungekey` kullanilir.

Key'in dogru calistigini dogrulamak icin:

```bash
systemctl enable munge --now
munge -n | unmunge
```

Ciktida `STATUS: Success (0)` görmek gerekir.

> **Önemli:** Bu key compute node'lara da birebir kopyalanacaktir. Farkli key kullanilirsa node'lar birbiriyle iletisim kuramaz.

### 6. Spool ve Log Dizinlerinin Hazirlanmasi

```bash
mkdir -p /var/spool/slurmctld
chown slurm:slurm /var/spool/slurmctld

touch /var/log/slurm/slurmctld.log
chown slurm:slurm /var/log/slurm/slurmctld.log
```

### 7. slurmctld Servisinin Root ile Calistirilmasi

slurmscriptd alt süreci root yetkisi gerektirdigi icin systemd override olusturulur:

```bash
mkdir -p /etc/systemd/system/slurmctld.service.d/
```

`/etc/systemd/system/slurmctld.service.d/override.conf` dosyasi olusturulur:

```ini
[Service]
User=root
Group=root
```

### 8. slurm.conf Düzenleme

`/etc/slurm/slurm.conf` dosyasi cluster'a göre düzenlenir:

```conf
# Cluster Identity
ClusterName=mycluster
SlurmctldHost=master

# Authentication
AuthType=auth/munge

# Logging
SlurmctldLogFile=/var/log/slurm/slurmctld.log
SlurmdLogFile=/var/log/slurm/slurmd.log

# Process IDs
SlurmctldPidFile=/var/run/slurmctld.pid
SlurmdPidFile=/var/run/slurmd.pid

# Scheduling
SchedulerType=sched/backfill
SelectType=select/cons_tres
SelectTypeParameters=CR_Core

# State saving
StateSaveLocation=/var/spool/slurmctld

# Node Definitions
NodeName=node01 NodeAddr=192.168.122.11 CPUs=3 RealMemory=3800 State=UNKNOWN
NodeName=node02 NodeAddr=192.168.122.12 CPUs=3 RealMemory=3800 State=UNKNOWN

# Partition Definition
PartitionName=normal Nodes=node01,node02 Default=YES MaxTime=INFINITE State=UP
```

### 9. slurmctld Baslatma

```bash
systemctl daemon-reload
systemctl enable slurmctld --now
systemctl status slurmctld
```

Dogrulama:

```bash
sinfo
```

Beklenen cikti:

```
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
normal*      up   infinite      2    unk node[01-02]
```

Node'larin `unk` (unknown) göstermesi normaldir — compute node'lar henüz kurulmamistir.

---

## Compute Node'lar Üzerinde Yapilacak Islemler

> Asagidaki islemler her compute node icin tekrarlanir (node01, node02).

### 1. OpenHPC Reposu Ekleme

Master'daki repo dosyasi kopyalanabilir veya RPM dogrudan kurulabilir:

**Yöntem A — Master'dan repo dosyasi kopyalama (master'da calistirilir):**

```bash
scp /etc/zypp/repos.d/OpenHPC.repo root@192.168.122.11:/etc/zypp/repos.d/
```

> **Not:** Bu yöntemde GPG key kopyalanmadigi icin `--no-gpg-checks` kullanmak gerekecektir.

**Yöntem B — RPM'i dogrudan kurma (compute node'da calistirilir):**

```bash
zypper --no-gpg-checks install -y http://repos.openhpc.community/OpenHPC/3/Leap_15/x86_64/ohpc-release-3-1.leap15.x86_64.rpm
```

### 2. Paket Kurulumu

```bash
zypper refresh
zypper --no-gpg-checks install -y ohpc-base ohpc-slurm-client munge
```

### 3. Munge Key Kopyalama (Master'da calistirilir)

```bash
scp /etc/munge/munge.key root@192.168.122.11:/etc/munge/munge.key
scp /etc/munge/munge.key root@192.168.122.12:/etc/munge/munge.key
```

> **Ön kosul:** Compute node'lara SSH key ile baglanmak icin master'da key olusturulup kopyalanmis olmali:
>
> ```bash
> ssh-keygen -t ed25519 -N "" -f /root/.ssh/id_ed25519
> ssh-copy-id root@192.168.122.11
> ssh-copy-id root@192.168.122.12
> ```

### 4. Munge Yapilandirma ve Dogrulama (Compute node'da calistirilir)

```bash
chown munge:munge /etc/munge/munge.key
chmod 400 /etc/munge/munge.key
systemctl enable munge --now
munge -n | unmunge
```

Ciktida `STATUS: Success (0)` görmek gerekir.

### 5. slurm.conf Kopyalama (Master'da calistirilir)

```bash
scp /etc/slurm/slurm.conf root@192.168.122.11:/etc/slurm/slurm.conf
scp /etc/slurm/slurm.conf root@192.168.122.12:/etc/slurm/slurm.conf
```

> **Önemli:** Tüm node'lardaki slurm.conf birebir ayni olmalidir.

### 6. slurmd Baslatma (Compute node'da calistirilir)

```bash
mkdir -p /var/log/slurm
touch /var/log/slurm/slurmd.log
chown slurm:slurm /var/log/slurm/slurmd.log
mkdir -p /var/spool/slurmd
chown slurm:slurm /var/spool/slurmd
systemctl enable slurmd --now
systemctl status slurmd
```

`active (running)` ve `slurmd started` mesajlari görülmelidir.

---

## Dogrulama

Tüm node'lar kurulduktan sonra master üzerinde:

```bash
sinfo
```

Beklenen cikti:

```
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
normal*      up   infinite      2   idle node[01-02]
```

Node'larin `idle` durumunda olmasi cluster'in hazir oldugunu gösterir.

---

## Lab Ortami Bilgileri

| VM      | IP              | RAM  | Disk | vCPU | Rol                      |
|---------|-----------------|------|------|------|--------------------------|
| master  | 192.168.122.10  | 6GB  | 50GB | 2    | slurmctld, munge, NFS    |
| node01  | 192.168.122.11  | 4GB  | 30GB | 3    | slurmd — compute node    |
| node02  | 192.168.122.12  | 4GB  | 30GB | 3    | slurmd — compute node    |

- **Host OS:** Ubuntu 24.04 LTS Desktop
- **VM OS:** openSUSE Leap 15.6
- **Virtualization:** KVM + libvirt + virt-manager
- **Network:** virbr1 (NAT), gateway 192.168.122.1
- **Disk format:** qcow2 thin provisioned, ext4

---

## Karsilasilan Sorunlar ve Cözümleri

### slurmctld "Failed to set GID to 0" hatasi

**Sebep:** Systemd servis dosyasi `User=slurm` ile calistiriyor ama slurmscriptd root gerektiriyor.

**Cözüm:** Systemd override ile `User=root` ayarlamak (bkz. Master Node adim 7).

### slurmctld log dosyasi bulunamadi

**Sebep:** `/var/log/slurm/` dizini var ama log dosyasi olusturulmamis.

**Cözüm:**

```bash
touch /var/log/slurm/slurmctld.log
chown slurm:slurm /var/log/slurm/slurmctld.log
```

### GPG key hatasi (ohpc-release kurulumunda)

**Sebep:** ohpc-release RPM'i GPG key'i iceriyor ama zypper RPM'i kurmadan önce imzasini dogrulamaya calisiyor.

**Cözüm:** `--no-gpg-checks` parametresi kullanilir. RPM kurulduktan sonra key sisteme import edilir.

### "create-munge-key: command not found"

**Sebep:** `create-munge-key` RHEL/CentOS'a özgü bir yardimci script, openSUSE'de bulunmaz.

**Cözüm:** `mungekey --create` kullanilir. Genellikle munge paketi kurulurken key otomatik olusur.

### OpenHPC RPM indirme linki calismadi

**Sebep:** GitHub release linkleri zaman zaman degisebilir veya dosya adi farkli olabilir.

**Cözüm:** `repos.openhpc.community` üzerinden veya master'daki repo dosyasini kopyalayarak kurulum yapilir.