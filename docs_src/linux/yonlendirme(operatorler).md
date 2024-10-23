**Linux komutlar**ını kullanırken ve shell scriptleri yazarken en çok kullanılan etmenlerden birisi yönlendirmelerdir.(Redirection) Ayrıca yönlendirmeler **linux terminali**nin en güçlü ama en çok yanlış anlaşılan konseptlerinden birisidir. Bu yüzden bu konuyu en temele inerek anlatmak istiyorum.

**>** operatörü (**genellikle bazı sembolleri operatör olarak adlandırırız. >,<,-,+**) komutlardan aldığımız **çıktıyı(output)** yönlendirmeye yarar. Bunu çok basit bir şekilde örneklendirecek olursak;

_Daha önceden öğrendiğimiz [temel linux komutları](https://www.berkbal.com/temel-linux-komutlari/)ndan birisi olan **ls,** bulunulan dizindeki dosyaları listelemeye yarar. Bunu biliyoruz. Komutu çalıştırdığımızda ekrana gelen yazıların hepsi birer **çıktıdır.(output)**_

Yönlendirmeler de tam olarak burada devreye giriyor. Bazı durumlarda ls komutunun çıktısını ekrana yazdırmak yerine bir dosya içerisinde saklamak isteyebiliriz. Bunu da operatörler sayesinde gerçekleştiriyoruz. Aşağıdaki örneğe bakalım;

```
$ ls > dosyalarin_listesi
```

_Dosyalarin_listesi_ isimli dosyamızda artık **ls komutu**nun çıktısı, yani bulunan dosyalarımızın listesi var.

Fakat **> operatörü** ezici?!(clobbering) bir operatördür. Eğer çıktıyı içerisinde yazı olan bir dosyaya yönlendiriyorsak **dosyanın içerisindeki herşeyi silerek yeni çıktıyı dosyaya yönlendirecektir.** Özellikle log dosyası tutarken bu problemle sürekli karşı karşıya kalabilirsiniz. Bu durumu önlemek için de **> yerine >> operatörünü kullanabilirsiniz. Her ikisi de birebir aynı şekilde çalışıyor fakat tahmin edebileceğiniz üzere >> operatörü gelen çıktıyı var olan dosyanın sonuna ekliyor, üzerine yazmıyor.**

Bazı programlar da kullanıcıdan veya komut satırı üzerinden input ile çalışıyor olabilir. **Az önce test ettiğimiz operatörün tersi olan < operatörü** ile de bu durumu sağlayabiliriz. Diyelim ki mail_icerigi.txt adında bir dosyamız var ve bu dosyanın içerisindeki bütün yazıları birine mail olarak göndermek istiyoruz;

```
$ mail berkbal94@gmail.com < mail_icerigi.txt
```

Bu operatörü kullanarak programlara veya bazı komutlara dışarıdan girdi(input) gönderebiliriz. İlerleyen zamanlarda https://www.shellscript.sh/ yazarken bu konuya sürekli değineceğiz. Şimdilik bu kadarını biliyor olmamız yeterli.
