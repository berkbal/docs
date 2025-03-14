# OpenWRT WAP Kurulumu

## Gerekli Paketlerin Yuklenmesi

1. **Modeme SSH ile baglanilir:**
   ```bash
   ssh root@192.168.1.1
   ```

2. **wpad-basic-mbedtls paketini sil:**
    wolf-ssl ile conflict olan paketi onceden silmek gerekiyor.
   ```bash
   opkg remove wpad-basic-mbedtls
   ```

3. **wpad-wolfssl ve usteer paketlerini yukle:**
   ```bash
   opkg update
   opkg install wpad-wolfssl
   opkg install usteer
   ```

---

## OpenWRT Arayuzunde Yapilan Islemler

1. **Hostname degistirme:**
   - OpenWRT GUI'ye gir.
   - **System > System** sekmesine git.
   - **Hostname** alanina yeni ismi yaz.
   - **Save & Apply** butonuna bas.

2. **LAN DHCP'yi kapatma:**
   - **Network > Interfaces** sekmesine git.
   - **LAN** arayuzunu sec ve **Edit** butonuna bas.
   - **DHCP Server** sekmesine git, **Disable DHCP** secenegini sec.
   - **Save & Apply** butonuna bas.

3. **WAN arayuzunu sil ve WAN portunu bridge arayuzune ekle:**
   - **Network > Interfaces** sekmesine git.
   - **WAN** arayuzunu sec ve **Remove** butonuna tikla.
   - **Network > Switch** sekmesine git.
   - **WAN portunu** **br-lan** ile bagla.
   - **Save & Apply** butonuna bas.

 4. **Wireless Security Ayarları**

![Wireless Security Ayarları](image.png)

 5. **Roaming Ayarlari**

 ![Roaming Ayarlari](image-1.png)

## Yüklenen Eklentilerin Ayarları

### Usteer

- Asagidaki ayarlar AP1 icin yapilmistir. AP2'de usteer ayarlanirken ap1,ap3 ve varsa diger AP lerin ip adreslerinin verilmesi gerekmektedir.
- option key ayari her cihazda ayni olmalidir.


```
config usteer
    option 'network' 'lan'
    option 'syslog' '1'
    option local_mode '0'
    option 'ipv6' '0'
    option 'debug_level' '2'
    option signal_diff_threshold '15'
    option load_balancing_threshold '30'
    option local_sta_limit '30'
    option remote_update '1'

config node
    option host '192.168.1.40'  # AP2'nin IP adresi
    option key 'BUTUN-ROUTERLARDA-AYNI-OLACAK-OZEL-BIR-PAROLA (32 karakter olması onerilir)'

config node
    option host '192.168.1.50' # AP3'un IP Adresi
    option key 'BUTUN-ROUTERLARDA-AYNI-OLACAK-OZEL-BIR-PAROLA (32 karakter olması onerilir)'
```