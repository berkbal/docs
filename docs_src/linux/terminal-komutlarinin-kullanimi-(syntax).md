Genellikle terminale yazdığınız ilk kelime çalıştırmak istediğimiz komuttur. [Başlamadan Önce](https://berkbal.github.io/docs/linux/linux-komutlari/) isimli yazımda sizlere _date_ komutundan bahsetmiştim. Bu komut bize komutun çalıştırıldığı zamanın tarihini ve zamanını gösteriyordu.

## **Arguments – Argümanlar**

Kullanabileceğimiz diğer bir komut ise belirtilen bilgileri kullanıcıya geri gösteren _echo_ komutu. Echo komutunu tek başına çalıştırdığımızda herhangi bir şey olmayacaktır çünkü echo komutu bir argüman ile birlikte çalışan bir komuttur. Echo komutu, kendisine verdiğimiz argümanı(bilgiyi) bize geri döndürür.

```
$ **echo foo** 
foo
```
Yukarıdaki örnekte gördüğümüz üzere argümanımız foo olduğu için bilgisayarımız bize foo diyerek cevap verdi.

Echo komutuna istediğimiz kadar argüman gönderebiliriz. _Echo_ komutundan sonra ne yazarsak yazalım bilgisayarımız bunları argüman olarak algılayacaktır. Eğer birden fazla kelime yazdırmak istiyorsak _echo_ komutunu bu şekilde kullanabiliriz.

```
$echo foo bar
foo bar
```

Argümanlar genelde aralarında boşluklar bırakılarak birbirlerinden ayrılır. Ekstra boşluklar görmezden gelinir ve iki argüman bir adet boşluk içererek bize yansıtılır. Fakat Terminale(Komut Satırı) bu boşlukların da bir argüman olduğunu söylemek istersek “ işareti ile bunu belirtmemiz gerekir.

```
$echo"foo" "bar"
foo bar
```

**Options –** **Seçenekler**

Daha önceden gördüğümüz _date_ komutunu hatırlıyor musunuz? Bu komut varsayılan haliyle bize komutun kullanıldığı tarihi ve saati söylüyor fakat ya biz UTC formatında bir bilgi istiyorsak? Bunun için _date_ komutunu _–utc_ optionı ile birlikte kullanabiliriz. Komutu bu şekilde kullandığımız zaman bilgisayar bizim UTC formatındaki zamanı istediğimizi bilerek bize buna uygun bir sonuç gönderiyor.

```
$ date --utc
Tue 12 Oct 2021 12:38:44 PM UTC
```

Genelde komut seçeneklerini kısaltarak kullanırız. Bir seçeneğin(option) kısa versiyonu tek çizgi ile yazılan versiyonudur. Date komutunu _date -u_ şeklinde kullandığımızda da aynı şekilde sonuç aldığımızı görebiliriz. Kendi terminalinizde bunu deneyebilirsiniz.

Diyelim ki _date_ komutundan bugünün verileri yerine bir önceki günün verilerini istiyoruz. Bunu nasıl yapabiliriz? Bunun için _date_ komutuna _–date_, kısa haliyle _-d_ seçeneğini gönderebiliriz. Bu seçeneğe de bir argüman göndererek bilgilerini istediğimiz tarihi belirtebiliriz. Kafa karışıklığını önlemek için oluşturduğumuz komutu parçalara bölerek göstereyim:

1. date  
2. date –date  
3. date –date yesterday -u

Birinci adımda çalıştırmak istediğimiz komutu girdik.  
İkinci adımda çalıştırmak istediğimiz komuta bir seçenek gönderdik.  
Üçüncü adımda ise komuta gönderdiğimiz seçeneğe(option) bir adet argüman gönderdik.(_yesterday_)  
_-u_ ise yukarıda da belirttiğim üzere _–utc_ seçeneğinin kısaltılmış hali.

```
$ date --date yesterday -u
Mon 11 Oct 2021 12:50:40 PM UTC
```

Yukarıdaki örnekte de gördüğünüz üzere bazı optionlar çalışmak için argümanlara ihtiyaç duyarlar.

Daha önce çalıştırdığınız bir komutu tekrar hızlıca almak için Yukarı Ok tuşunu kullanabilirsiniz. Daha önceki ve sonraki komutları almak için de ok tuşlarını kullanarak yukarı ve aşağı hareket edebilirsiniz.

Ayrıca Sol ok ve Sağ ok tuşları, tek bir komut içinde hareket etmenizi sağlar. Geri tuşu(backspace) ile birlikte bu tuşlar komutumuzun bölümlerini değiştirmenize ve onu isteğimize göre yeni bir komuta dönüştürmemize olanak tanır. Enter tuşuna her bastığınızda, değiştirilen komutu terminale gönderirsiniz ve tam olarak sıfırdan yazmışsınız gibi çalışır.
