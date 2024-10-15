# Temel Linux Komutları

Artık dizinler ve dosyalar hakkında temel bir bilgiye sahibiz. Ayrıca komut satırı aracılığıyla bilgisayarımız aracılığıyla iletişime geçebilir seviyeye geldik. Bu bölümde ise “en çok” kullanacağımız komutların birkaçından bahsetmek istiyorum.

## Ls komutu

Bir dizin içerisinde dosya/dizin oluşturmadan önce bilmemiz gereken şeylerden birisi de “Aceba bu dizinin içerisinde ne var?” sorusunun cevabıdır diye düşünüyorum. Grafik arayüz aracılığı ile bunu çok basit bir şekilde klasörü açarak gerçekleştirebiliriz. Komut satırından da ls programını, veya komutunu kullanarak bir dizinin içerisinde neler olduğunu görebiliriz.

```
$ ls
Desktop Documents Music Photos
```

ls komutu oldukça kompakt bir çıktı verir. Çoğu terminal/terminal emulatoru dizinleri, alt dizinleri ve belirli dosya tiplerini renkli bir çıktı şeklinde bize gösterir. Standart dosyalar herhangi bir renk ayarına sahip değildir. Ls komutunu kendi bilgisayarınız üzerinde deneyerek bunu görebilirsiniz. Bir taraftan grafik arayüzünüzü açıp bir diğer taraftan da terminal ile ls komutunu kullanarak karşınıza gelen çıktıya bakarak bunu gözlemlemenizi tavsiye ederim. Eğer sizin çıktınız renkli değilse ls komutuna –color optionunu göndermeyi deneyebilirsiniz.

```
$ ls --color
```
## Man, info ve apropos

Linux komutları hakkındaki bir makalede bu komutları size gösteriyor olmam garip olsa da linux komutlarının(aslında bunlar birer program) birlikte çalışabileceği optionlar hakkında bilgi almak için bu komutların manual sayfalarına bakabilirsiniz.
```
$ man ls
```
Burada man komutu içerisine ls argümanını alarak bize ls komutunun manual sayfasını getirecek. Ok tuşları ile gelen ekran içerisinde gezinebilirsiniz. Q tuşu ile bu ekrandan çıkış yapabilirsiniz. Kullanıcı dökümantasyonunu farklı bir şekilde almak istiyorsak info komutunu kullanabiliriz.
```
$ info ls
```
Bu yöntem oldukça kompleks GNU Programlarının nasıl kullanılacağını öğrenmek için oldukça etkilidir. Ayrıca bu dökümantasyonları emacs isimli text editöründe okuyabilirsiniz. Okunabilirliği kesinlikle arttırıyor.

Az önce size bahsettiğim komutlardan sonra “bunlar bu kadar da önemli değilmiş” dediğinizi hissedebiliyorum. Şimdi bilgi almak konusunda hayatımızı kurtarıcak olan bir komuttan bahsetmek istiyorum.

## Apropos komutu

Apropos komutu ne yapmak istediğimizi bildiğimiz ama hangi komut ile yapacağımızı bilmediğimiz zaman oldukça işimize yarar. Biraz garip bir cümle oldu fakat bunu başka türlü açıklayamazdım. 🙂 Diyelim ki bir dosyanın adını değiştirmek istiyoruz fakat bunu hangi komutun yaptığını bilmiyoruz. Bu komutu öğrenmek için apropos komutunu kullanabiliriz.
```
$ apropos rename
...
mv (1) - move (rename) files
prename (1) - renames multiple files
rename (2) - change the name or location of a file
…
```
Komutumuzu bu şekilde kullandığımız zaman apropos bizim için bütün manual sayfalarını tarayıp içerisinde “rename” yani isim değiştirme ile alakalı olan kısımları bizim önümüze getiriyor. Ayrıca evet, Google’da aramaktan daha hızlı bir çözüm olduğu doğru. 🙂

Burada dikkatinizi çekmek istediğim bir konu var. Apropos komutundan karşımıza gelen çıktıya dikkatli baktığımızda bazı komutların yanında bazı numaraların olduğunu farkedebiliriz. Bu numara karşımıza gelen komutların hangi section’da olduğunu belirtir. yinelde section’u “1” olan programlar komut satırında kullanılabilir. Biz sadece komut satırında kullanabileceğimiz programları listelemek istiyorsak apropos’a bir option göndererek sadece section’u 1 olan programları bize göstermesini sağlayabiliriz.
```
$ apropos -s 1 rename
...
mv (1) - move (rename) files
prename (1) - renames multiple files
...
```
Section numarası kesinlikle ÇOK ÖNEMLİ?! Değil fakat section 1’deki manual sayfaları genellikle komut satırında kullanabileceğimiz programlar/komutlar.

## mv komutu

Apropos çıktımızdan öğrendiğimiz üzere mv komutu ile dosyalarımızın isimlerini bu komut ile değiştirebiliriz. Fakat bu komut aslında “move” anlamında. Yani dosyalarımızı bir dizinden farklı bir dizine taşımaya yarıyor. Fakat mv komutunu aşağıdaki şekilde kullanarak dosyalarımızı tekrar isimlendirebiliriz.
```
$ mv eski_isim yeni_isim
```
Sistem ayarlarınıza bağlı olarak dosyanızı tekrar isimlendirirken herhangi bir uyarı ile karşılaşmazsınız. Yani eğer bulunduğunuz dizinde dosyanıza vereceğiniz yeni isime sahip başka bir dosya varsa bu bir problem olabilir. Bunun için mv komutuna -i option’unu göndererek kullanmakta kesinlikle fayda var.
```
$ mv -i eski_isim yeni_isim
```
Ayrıca az önce yukarıda da bahsettiğim gibi mv komutunun gerçek işlevi dosyalarımızı bir dizinden alıp başka bir dizine taşımak. Eğer mv komutunun son argümanı bulunulan dizinden farklı bir dizini gösteriyorsa komutumuz taşıma işlemi gerçekleştirecektir.
```
$ mv herhangi_bir_dosya bir_tane_daha_dosya ucuncu_farkli_bir_dosya ~/belgelerim
```
Eğer belgelerim adında bir dizinimiz varsa mv komutu dosyalarımızı bu dizine taşıyacaktır. Eğer böyle bir dizin yoksa aşağıdaki şekilde bir hata mesajı alabiliriz.
```
$ mv herhangi_bir_dosya bir_tane_daha_dosya ucuncu_farkli_bir_dosya ~/belgelerim
mv: target ‘belgelerim’ is not a directory
```
## mkdir Komutu

Eee, dizin/klasör nasıl oluşturuyoruz? Mkdir komutu ile!
```
$ mkdir ~/belgelerim
```
Var olan bir dizini nasıl siliyoruz? Rmdir komutu ile. 🙂
```
$ rmdir ~/belgelerim
```
Eğer bir dizinin içerisinde alt bir dizin oluşturmak istiyorsak (diyelim ki bu halihazırda var olan dizinin adı foo) mkdir komutunu aşağıdaki gibi kullanabiliriz.
```
$ mkdir -p ~/foo/bar
```
Eğer rmdir komutu ile silmek istediğimiz dizin içerisinde dosyalar barındırıyorsa rmdir komutu bize hata vericektir. İçerisinde dosya olan bir klasörü nasıl silebiliriz? Rmdir komutuna -R optionunu göndererek.  
Hadi bunu test edelim! Ilk önce alistirma adında bir dizin oluşturup bu dizinin içerisine girelim.
```
$ mkdir ~/alistirma
$ cd ~/alistirma
```
## cp, rm ve rmdir komutları

Cp komutumuzu kullanarak oluşturduğumuz dizinlerin içerisine dosya kopyalayabiliriz! Bilgisayarımızda hali hazırda bulunan bazı dosyaları kullanarak bu testi gerçekleştirebiliriz. Cd komutu ile alistirma isimli dizinimize az önce girdik.
```
$ cp /etc/fstab /etc/hosts /etc/issue /etc/motd .
$ ls
fstab hosts issue motd
```
Dizinler ile alakalı yazdığım bir önceki makalede sizlere . ve .. işaretlerinden bahsetmiştim. . şaretini komutunuzun sonuna koymayı unutmayın! Eğer hatırlarsanız . işaretinin komut satırında “bu dizin” anlamına geldiğini söylemiştim. Bu işareti cp komutuna bir argüman olarak gönderdikten sonra belirttiğimiz dizinleri bulunduğumuz dizine kopyalayabiliriz. Veya içerisinde bulunduğumuz dizinin içerisindei bütün dizinleri/ve dosyaları farklı bir yere kopyalayabiliriz.
```
$ cp -R . ~/hedef_dizin
```
Hadi şimdi oluşturduğumuz alistirma isimli dizini ve içerdiği alt dizinleri silelim.
```
$ cd ~
$ rmdir alistirma
rmdir: failed to remove ‘alistirma’: Directory not empty
```
Gördüğünüz üzere rmdir komutu ile içerisinde dosya bulunan dizinleri direkt silemiyoruz. Fakat rm komutuna -R optionunu gönderek bunu yapmamız mümkün.
```
$ rmdir -R alistirma
```
## Cat ve Less Komutu

Bir dosyanın içeriğini görüntülemek için her zaman text editörüne ihtiyaç duymayız. Eğer amacımımız sadece dosyanın içeriğini görüntülemek ise cat komutunu kullanabiliriz.
```
$ cat herhangi_bir_metin_dosyasi.txt
Eeeeeeeeey! Terminal kullanmayı en iyi biz biliriz!
```
Eğer içeriğini görüntülemek istediğimiz dosya çok uzunsa less komutunu kullanmamız daha mantıklı olabilir. Less komutu ile metin dosyamızı görüntüleme ekranında ok tuşlarıyla gezinip q tuşu ile bu ekrandan çıkabiliriz.
```
$ less herhangi_bir_metin_dosyasi.txt
```
An itibariyle dosya silme, dosya kopyalama, dizin/klasör oluşturma, dosya ismi değiştirme, dosya silme, komutların manual sayfalarına erişme ve bulunulan dizini görüntüleyebiliyoruz! Henüz bu komutları ezberlemediğinizi düşünerek aşağıya küçük bir liste çıkartıyorum, bu listeden faydalanabilirsiniz!

Bu derste öğrendiğimiz komutlar:  
ls komutu : dizin içeriği görüntülemeye yarar.  
man komutu : komutarın/programların manual sayfalarına erişmemize yarar.  
info komutu : komutlar/programlar hakkında bilgi almamıza yarar.  
apropos komutu : manual sayfaları içerisinde içerisine gönderdiğimiz argümanı arar.  
cp komutu : dosya kopyalamaya yarar.  
mv komutu : dosyaları/dizinleri taşımaya ve yeniden adlandırmaya(isim değiştirme) yarar.  
rmdir komutu : dizinleri silmemize yarar.  
mkdir komutu : dizin oluşturmamıza yarar.  
cat komutu : dosyaların text içeriğini görüntülememize yarar.  
less komutu : uzun text dosyalarını görüntülememizde daha kullanışlıdır.