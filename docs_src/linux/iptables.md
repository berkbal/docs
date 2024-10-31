# Iptables 

## Iptables Nedir? 

Iptables Linux çekirdeği içerisinde bulunan güvenlik duvarı modülünü komut satırı aracılığıyla kontrol etmemizi sağlayan bir araçtır. Iptables sayesinde gelen trafiği başka bir yere yönlendirebilir, reddedebilir veya kabul edebiliriz.  

Bu yazıyı okurken iptables’ın nasıl kullanıldığını anlamayabilirsiniz, örneklere geçtiğimiz zaman muhtemelen sorunsuz bir şekilde iptables kullanabiliyor olucaksınız. Ayrıca kullanılan terimlerin ingilizce hallerini de özellikle parantezler içerisinde belirtmeye çalıştım. İlerliyen zamanlarda mutlaka bu konuda araştırma yapmanız gerekicektir. Iptables konusunda araştırma yaparken İngilizce yapmanızı tavsiye ederim. Bu konuda Türkçe kaynak pek bulunmuyor. 

## Iptables Nasıl Çalışır? 

Iptables gelen network paketleri üzerinde işlem yapmak için kural sistemini kullanır. Bu kurallar aşağıdaki bileşenlerden oluşur: 

1. Tablolar (Table): Tablolar, benzer kuralları gruplandıran dosyalardır. Bir tablo, birkaç kural zincirinden oluşur. 

2. Zincirler (Chains): Bir zincir, bir dizi kuraldan oluşur. Bir paket alındığında, iptables uygun tabloyu bulur ve paket, bir eşleşme bulunana kadar kural zinciri üzerinden filtrelenir. 

3. Kurallar (Rules): Kurallar bir paketin belirli koşullara uyup uymadığını kontrol eden ifadelerdir. Eğer paket bu koşullara uyarsa, kuralın hedefi olan işlemi gerçekleştirir.

4. Hedefler (Targets): Hedefler bir paketle ne yapılacağına karar verilen yerlerdir. Paket kabul edilebilir (ACCEPT), düşürülebilir (DROP) veya reddedilebilir. (REJECT) 

### Tablolar (Tables) 

Iptables üzerinde çalışan 4 adet varsayılan tablo vardır. Bu tablolar birbirlerinden farklı amaçlarla hazırlanan kural zincilerini yönetmek için kullanılır. 

1. Filtre Tablosu (Filter): Varsayılan paket filtreme tablosu bu tablodur. Hangi paketlerin kullandığımız internet ağına(network) girebileceğini ve çıkabileceğini bu tablo filtreler. 

2. Nat Tablosu (NAT): Uzakta bulunan ağlara(networklere) yönlenicek olan paketlerin yönlendirilme kurallarını içeren tablo. 

3. Mangle Tablosu (Mangle): Bu tablo, ağ paketlerinin çeşitli özelliklerini değiştirmek veya "manipüle etmek" için kullanılır. Mangle table genellikle ağ paketlerinin başlıklarını değiştirmek, belirli işaretler eklemek, TTL (Time To Live) değerini değiştirmek veya paketlerin yönlendirilmesini değiştirmek gibi işlemler için kullanılır. 

4. Raw: Takip edilmesi ve üzerinde işlem yapılması gerekmeyen veya bir nedenden dolayı istenmeyen internet paketleri için bu tablo kullanılır. 

### Zincirler (Chains) 

Zincirler tabloların içerisindeki kural listeleridir. Listeler, tablolara gelen paketlerin nasıl değerlendirileceğini ve üzerinde nasıl işlemler yapılacağını belirler. Bu işlem 4 farklı adımdan oluşur; 

1. INPUT: Iptables’ın çalıştığı bilgisayar üzerindeki bir uygulamadan gelen paketleri işleyen adımdır. Filter ve Mangle tablosunda bulunur. 

2. OUTPUT: Kullanılan bilgisayarda çalışan uygulamalardan ve servislerden dışarıya çıkan paketlerin yönetildiği adım. Bütün tablolarda bu zincir bulunur. 

3. FORWARD: Sistemde bulunan network interfaceleri arasındaki paketlerin yönlendirilmesi ile alakalı olan adım. Filter, Mangle ve Security tablolarında bulunur. 

4. PREROUTING: Paketler yönlendirilmeden önce üzerinde işlem yapmamızı sağlayan adım. İşlemler, paketlerin nereye yönleneceğinden ÖNCE gerçekleşir. NAT, Mangle ve RAW tablosunda bulunur. 

5. POSTROUTING: Paketler hedefe yönlendirildikten sonra işlem yapmamızı sağlayan adım. İşlemler, paketler yönlendikten SONRA gerçekleşir. NAT ve Mangle tablosunda bulunur. 

### Kurallar (Rules) 

Kurallar, eşleşen paketler için koşulları tanımlayan ifadelerdir. Her kural bir zincirin parçasıdır ve spesifik kritlerler içerir. (Hedef ip adresi, port numarası veya protokoller). Kuralların koşullarına uyan her paket target’a(hedef) yönlendirilir ve yönlendirilen pakete ne yapılacağı belirlenir. 

### Hedef (Targets) 

Target, kural kriterlerine uyan paketlere ne olacağını belirler. Bu işlemler; 

- ACCEPT: Paketin güvenlik duvarından(firewall) geçmesini sağlar. 

- DROP: Paketin güvenlik duvarından geçişini engeller fakat paketi gönderen kaynağa bu konu hakkında bir bilgi vermez. 

- REJECT:  Gelen paketi reddeder ve paketi gönderen kaynağa bir hata mesajı gönderir. 

- LOG: Paket bilgisini bir log dosyasına kaydeder. 

- SNAT: Açılımı “Source Network Address Translation"dır. Gelen paketin kaynak adresini değiştirir. 

- DNAT: Açılımı “Destination Network Adress Translation”dır. Gelen paketin hededf adresini değiştirir. 

- MASQUERADE: Dinamik olarak atanan IP'ler için bir paketin kaynak adresini değiştirir. 

### Iptables Nasıl Kurulur? 

Iptables çoğu Linux dağıtımında varsayılan olarak yüklü gelir. Iptables’ın kurulu olduğunu doğrulamak ve sürümünüzü öğrenmek için aşağıdaki komutu çalıştırabilirsiniz. 

```
iptables --version 
``` 

Debian Tabanlı Dağıtımlar İçin: 
```
apt-get update ; apt-get upgrade ; apt-get install iptables
```

Arch Linux Tabanlı Dağıtımlar için: 
```
pacman –Syu ; pacman –S iptables 
```
Kurulumdan sonra:
```
systemctl enable netfilter-persistent 
```
 

## Iptables Komutu Nasıl Kullanılır? 

Iptables komutu aşağıdaki düzende kullanılır; 

```
iptables [options] [chain(zincir)] [criteria(kriter)] -j [target(hedef)] 
```

Aşağıdaki tablodan en sık kullanılan iptables seçeneklerini görebilirsiniz. 
 
 | Seçenek         | Açıklama                                                |
|-----------------|---------------------------------------------------------|
| -A veya --append | Halihazırda var olan bir zincire ekstra kural ekler.    |
| -C veya --check | Bir zincir ile eşleşen bir kural var mı diye kontrol eder.|
| -D veya --delete| Bir zincirden kural siler.                               |
| -F veya --flush | Bütün iptables kurallarını siler.                        |
| -I veya --insert| Belirtilen zincire kural ekler.                          |
| -L veya --list  | Zincirin içerisindeki bütün kuralları listeler           |
| -N veya --new-chain | Yeni bir zincir oluşturur.                          |
| -v veya --verbose | Daha detaylı bir çıktı verir.                          |
| -X veya --delete-chain | Zinciri siler.                                    |

iptables komutu varsayılan olarak Filtre tablosu üzerinde işlem yapar. Farklı bir tablo kullanmak için, -t seçeneğini kullanabilirsiniz. (örneğin, NAT tablosu için -t nat kullanılabilir). 

Var Olan Kuralları Görmek 

```
sudo iptables -L 
```
 
Bu komutun çıktısı ```INPUT```, ```FORWARD``` ve ```OUTPUT``` zincirlerinin nasıl gözüktüğünü listeler. 

### Döngüsel Trafiği Aktif Etmek(Loopback Traffic) 

Kendi bilgisayarınızdaki trafik akışını aktif hale getirmek hem güvenlidir hem de bilgisayarınızda çalışan uygulamaların birbirleri ile iletişim kurmasını sağlar. Aşağıdaki komutu girerek bu trafiği aktif hale getirebilirsiniz. 

```
iptables -A INPUT -i lo -j ACCEPT 
```

### Özel Servisler İçin Trafiğe İzin Vermek 

Bazı servislerin kullanılmasına izin vermek için bazı portlardan trafik geçişine izin vermek gerekir. Aşağıdaki örnekleri inceleyebilirsiniz 

- HTTP trafiğine izin vermek için 
```
iptables -A INPUT -p tcp --dport 80 -j ACCEPT 
```
- SSH trafiğine izin vermek için 
```
iptables -A INPUT -p tcp --dport 22 -j ACCEPT 
```
- HTTPS trafiğine izin vermek için 
```
iptables -A INPUT -p tcp --dport 443 -j ACCEPT 
```

### Belirli Bir IP Adresinden Gelen Trafik İçin Ayar Yapmak 

Belirli bir ip adresinden gelen bütün trafiği kabul etmek için aşağıdaki komutu kullanabilirsiniz 
```
iptables -A INPUT -s [IP-address] -j ACCEPT 
```

Belirli bir ip adresinden gelen bütün trafiği droplamak için aşağıdaki komutu kullanabilirsiniz. 
```
iptables -A INPUT -s [IP-address] -j DROP 
```
Belirli bir IP adresi aralığından gelen trafiği reddetmek için aşağıdaki komutu kullanabilirsiniz. 
```
iptables -A INPUT -m iprange --src-range [IP-address-range] -j REJECT 
```
Paylaştığım komutlardaki ip adresi kısımlarını değiştirerek komutları kullanabilirsiniz. 

## Droplanmış Paketlerin Loglanması