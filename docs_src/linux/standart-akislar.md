# Standart Akışlar

Akışlar(pipelar) nasıl çalışır? Çalıştırılan her komut üç iletişim kanalını(akışları) kullanır.

### stdin 
(standard input) varsayılan olarak klavyeniz ile ne yazıyorsanız bu kanala aktarılır. "<" işareti kullanıldıktan sonra dosya adı verilerek bir komutun/programın içerisine veri alması sağlanabilir.

### stdout 

(standard output) varsayılan olarak terminal ekranında gördüğünüz her yazı bu kanaldan aktarılır. ">" işaretini kullanarak ekrandaki yazıları bir dosyaya aktarabiliriz. Bu işaret kullanılarak output bir dosyaya aktarılırsa dosyanun içeriğini tamamen silerek yeniden oluşturacaktır. ">>" işaretini kullanarak var olan dosyanın içeriğini silmeden dosyanın sonuna ekrandaki yazıları ekleyebiliriz.

### stderr 

(standard error) Komutların/programların hata mesajı göndermek için kullandığı kanaldır. Sadece karşılaştığımız hatalar üzerinden işlem yapmak istediğimiz zamanlarda işimize yarayacaktır.

Örnek:

```
$ ls *.bak > listfile
ls: *.bak: No such file or directory
```

Yukarıdaki örnekte .bak ile biten tüm dosyaların bir listesini istedik. Ancak bu dizinde böyle bir dosya yok. Eğer ls hata mesajını standart çıktıya gönderseydi (bu durumda komutun çıktısı listfile isimli dosyaya aktarılacaktı), listfile'ın içeriğine bakmadan bir sorun olduğunu anlayamayacaktık. Ancak ls mesajını standart hataya gönderdiği için bunu ekranda görebiliyoruz.

## Pipe (|)

Pipe işareti (|) kullandığımız komutun çıktısını(stdout) diğer programın standart input (stdin) kanalına yönlendirir.

```
$ ls -lR / | more
```

***more komutu bir dosyanın içeriğini terminal üzerinde sayfa sayfa görüntülemeye yarayan bir linux komutudur. Çıktısı çok uzun olan komutlarla birlikte kullanılabilir.***

Eğer ```ls -lR /``` komutunu more komutuna pipelamasaydık komutun çıktısını okumamız neredeyse imkansız olacaktı. Kendi terminalinizde deneyebilirsiniz.

Bazen bir komutun çıktısını bir dosyaya yönlendirmek isteyebiliriz fakat komut çalışırken çıktıyı da görmek isteyebiliriz. ```tee``` komutu tam olarak bunu yapar:

```
$ ls -lR / | tee allMyFiles
```

Çıktısı uzun süren komutları tee ile bir dosyaya yazarak çıktıyı canlı olarak izleyebiliriz. Ayrıca komutun hala çalışıp çalışmadığını da gözlemlememizi sağlar.

## Standart Akışları Yönlendirmek

Stdout'u yukarıdaki şekilde yönlendirdik. Şimdi diğerlerini inceleyelim.

| Akış | Numara |
| ---- | ---- |
| stdin | 0 |
| stdout | 1 |
| stderr | 2 |

Yukarıdaki tablodan hangi akışın hangi kanal numarasına sahip olduğunu öğrenebilirsiniz.

### Standart Error Yönlendirmesi (stderr)

Yukarıda yaptığımız gibi stdin'i yönlendirdiğimizde hata mesajları hala ekrana gelecektir. Örneğin:

```
$ ls /boyle-bir-dizin-yok > /dev/null
ls: /boyle-bir-dizin-yok: No such file or directory
```

Stderr'i tamamen yönlendirmek için, yukarıdaki tabloda belirtilen kanal numaralarını kullanabiliriz.

```
ls /boyle-bir-dizin-yok 2>/tmp/errors
$
```

Bu şekilde bir yönlendirme 2 numaralı kanalı(stderr) tamamen farklı bir dosyaya yönlendirecektir ve komut satırının çıktısında hatalar gözükmeyecektir.

***Shell scriptleri yazarken kullanışlı olabilir.***

Şimdi stdout ve stderr'i aynı dosyaya yönlendiren daha karmaşık bir yönlendirmeyi test edelim:

```
$ ls *.bak > listfile 2>&1
```

Buradaki & işareti komutu arkaplanda çalışırma amacı ile karıştırılmamalıdır. ```&``` işareti bu işlemde ***MUTLAKA*** ```>``` işaretine bitişik olmalıdır. 

Buradaki yazım şekli, 2 numaralı kanalı 1 numaralı kanala yönlendirecektir. 1 numaralı kanal ```stdout``` olduğu için komutun çıktısı ```listfile``` isimli dosyaya yazılacaktır. ***Yani hem hata mesajlarını hem komutun çıktısını listfile isimli dosyaya yazdırmış oluyoruz.***

***Çalıştırmak istediğiniz linux komutunu arkaplanda çalıştırmak için ```komut &``` şeklinde çalıştırabilirsiniz.***

Bu işlemleri pipe ile birleştirmek istediğimizde ise komutun sonuna pipe koyarak çıktıyı başka bir komuta yönlendirebiliriz.

Örnek: 

```
$ ls *.bak 2>&1 | more
```