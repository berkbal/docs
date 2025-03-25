**Routing tablosu (yönlendirme tablosu)**, bir ağ cihazının (genellikle bir router ya da işletim sistemi ağ katmanı) gelen/verilecek IP paketlerini **hangi ağ arayüzü veya sonraki adrese (next hop)** yönlendirmesi gerektiğini belirlemek için kullandığı bir tablodur.

### Temel Görevi:
Routing tablosu, "bu paketi nereye göndereyim?" sorusuna cevap verir. Hedef IP adresine göre en uygun yolu seçer.

---

## 🧩 Routing Tablosu Bileşenleri:
Her satır (kayıt) genellikle aşağıdaki bileşenlerden oluşur:

| Alan | Açıklama |
|------|----------|
| **Destination (Hedef)** | Hedef ağın IP adresi ve netmask’i (örnek: `192.168.1.0/24`) |
| **Gateway (Ağ Geçidi)** | Hedefe ulaşmak için verinin gönderileceği bir sonraki IP adresi |
| **Interface (Arayüz)** | Paketin gönderileceği fiziksel ya da sanal ağ arayüzü (örnek: `eth0`) |
| **Metric** | Yolun maliyeti (küçük olan daha cok tercih edilir) |
| **Flags** | Yolun aktif olup olmadığı gibi bazı ek bilgiler |

---

## 🔧 Routing Tablosu Nasıl Görüntülenir?

### Linux’ta:
```bash
ip route show
```
ya da eski sistemlerde:
```bash
route -n
```

### Örnek Çıktı:
```
default via 192.168.1.1 dev eth0
192.168.1.0/24 dev eth0 proto kernel scope link src 192.168.1.100
```

### Anlamı:
- `default via 192.168.1.1 dev eth0`: Hedef başka bir kayıta uymuyorsa, tüm trafiği `192.168.1.1` router'ına gönder (`default route`).
- `192.168.1.0/24 dev eth0`: 192.168.1.0 ağına gitmek için doğrudan `eth0` arayüzünü kullan.

---

## Routing Türleri:
1. **Statik Routing:** Elle ayarlanır.
2. **Dinamik Routing:** Protokoller (OSPF, BGP, RIP vb.) aracılığıyla otomatik öğrenilir.
3. **Default Routing:** Bilinmeyen ağlara çıkış için kullanılan genel yol (`default route`).

---

## Neden Önemlidir?
- Doğru yapılandırılmazsa paketler hedefe ulaşamaz.
- Karmaşık ağlarda yönlendirmenin otomatik veya optimize olması gerekir.