# Birden Fazla Dosya İle İşlem Yapmak

Terminal kullanmaya alıştıktan sonra genelde çok fazla işi genelde kısa yoldan yapmaya çalışacaksınız. Bunu başarmanın en kolay yollarından biri de aynı anda birden fazla dosya üzerinde çalışmaktır. Diyelim ki birden fazla dosyayı silmek istiyoruz, şimdiye kadar öğrendiğimiz bilgiler ile aşağıdaki yöntemi izleyebiliriz.
```
$ rm this 
$ rm that
$ rm here
$ rm there
```
Toplamda dört adet dosya silmek için dört adet komut girdik. Fakat rm komutu(dosya silme komutu) aynı anda birden fazla dosya ismini kullanarak işlem yapabilir.
```
$ rm here that there this
```
Bu şekilde tek bir satır komut ile dört adet dosyayı silebiliriz.

## Joker Karakterler ve Wildcardlar(Globbing)

Joker karakterler linux terminali üzerinde mümkün olan en az karakterle birden çok dosya üzerinde işlem yapma konusunda yardımımıza yetişir. Shell, yani kabuk bu karakterleri komutların etkilemesini istediğimiz dosyaları belirtmek için kullandığımız işaretler olarak algılar. Bu karakterlere genelde joker karakterler denir çünkü bunlar, **kart** **oyuncularının istediği herhangi bir kartı temsil etmek için kullandığı joker kartlar gibidir.**

### “*” İşareti

Aşağıdaki şekilde bir dizin hayal edelim,
```
$ ls
here that there this
```
Bu dizin içerisindeki bütün dosyaları silmek istiyorsak * wildcard işaretini kullanabiliriz.
```
$ rm *
```
Yıldız işareti kendi başına kullanıldığında . ile başlayan gizli dosyalar haricindeki bütün dosyaları ifade eder. Bu nedenden dolayı rm komutuna . işareti ile başlamayan bütün dosyaların ve dizinlerin isimlerini parametre olarak gönderip işlemi gerçekleştirmiş oluruz.

* işaretini diğer karakterler ile kombine edebiliriz. Hayal ettiğimiz dizinde sadece t harfi ile başlayan dosyaları silmek için bu joker karakteri aşağıdaki gibi kullanabiliriz,
```
$ ls
here that there this

$ rm t*
$ ls
here
```
Komutu bu şekilde kullandığımızda Terminal(Kabuk) önce t karakterine baktı, sonra yıldız işareti ile geriye kalanları tamamlayarak dosya silme komutunu çalıştırdı.

Yıldız jokerini genelde belirli bir uzantıya sahip olan dosyaları silmek için kullanırız.
```
$ rm *.jpg
```
Yukarıdaki komut uzantısı jpg olan bütün dosyaları silecektir.

### “?” İşareti

Soru işareti, yıldız karakterine çok benzer. **Aralarındaki tek fark soru işareti sadece bir adet karakterin yerini alır.**

```
$ ls task*****
task  taskA  taskB  taskXY
$ ls task?
taskA  taskB
$ ls task??
taskXY
```