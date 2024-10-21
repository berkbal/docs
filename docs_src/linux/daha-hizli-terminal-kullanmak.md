# Daha Hızlı Terminal Kullanmak

Siyah arkaplanlı komut satırında bilgisayar kullanmak ne kadar havalı bir aktivite de olsa, uzun işlemler için zorlayıcı ve sinir bozucu olabiliyor. Bu bölümde komut satırını nasıl daha hızlı kullanabileceğimizden bahsetmek istiyorum.

## Otomatik Tamamlama

Tab tuşunu komut satırında kullanarak oldukça fazla vakit kazanabiliriz.

Tab tuşunun otomatik tamamlamaya yarayan bir işlevi var. 

Örneğin “asdfasdfasdfasdfasdkf.txt” isimli oldukça karışık isimli bir dosyamız var diyelim. Bu dosyayı mv komutu ile bulunduğu yerden başka bir yere taşımak istediğimizde bu karışık dosya ismini elimizle tek tek yazacak mıyız? Tabiki de hayır. 

mv komutunu yazdıktan sonra dosya isminin ilk birkaç harfini yazıp Tab tuşunu kullandığımızda Terminal otomatik olarak dosya isminin devamını bizim için tamamlayacaktır. Eğer dosya adı otomatik olarak tamamlanmamışsa, yazdığımız dosya isminin ilk birkaç harfi ile başlayan başka dosyalar da bulunduğumuz dizinde mevcut demektir. Bu durumu düzeltmek için işlem yapmak istediğimiz dosyanın adının birkaç harfini daha yazıp tekrar Tab tuşuna basabiliriz veya iki kere Tab tuşuna basarak terminalden bize yardımcı olmasını isteyebiliriz. Bu işlemden sonra Terminal bize girdiğimiz harflerle başlayan dosyaların isimlerini listeleyecektir.

## Kopyalama ve Yapıştırma (Copy & Paste)

Komut satırında çalışıyor olmamız grafık arayüz kullandığımız zamanlarda alışık olduğumuz bazı kolaylıkları kullanmayacağımız anlamına gelmez. Kes ve yapıştır, burada diğer işletim sistemlerindeki davranışından biraz farklı çalışsa da, çok kısa bir süre sonra alışacaksınız.

Kopyalama İşlemi: **Ctrl+Shift+C** veya kopyalanmak istenen kelimeye üç kere sol klik atılarak,
Yapıştırma İşlemi: **Ctrl+Shift+V** veya mouseunuzun orta tuşu ile gerçekleştirilebilir. Artık dünyada orta tekerleği olmayan iki tuşlu mouselardan kalmadı fakat her farenizdeki her iki tuşa da aynı anda basarsanız Terminal bunu middle click olarak algılayacaktır.

## Komut Geçmişi

Klavyenizdeki yukarı ve aşağı tuşlarını kullanarak daha önceden kullandığınız komutları görebilirsiniz. Aynı komutu veya aynı komutun bir benzerini tekrar kullanmak istediğinizde bu yöntem oldukça fazla zaman kazandıracaktır. Ayrıca **history** komutunu kullanarak daha önceden yazdığınız komutların bir çıktısını görebilirsiniz.

**Ctrl+A** ile satırın en başına, **Ctrl+E** ile de satırın en sonuna gidebilirsiniz. Ayrıca **Ctrl** tuşuna basılı tutarak **ok tuşlarını** kullanırsanız her bir harfi değil de her bir kelimenin ilk harfine işaretçiyi götürebilirsiniz.