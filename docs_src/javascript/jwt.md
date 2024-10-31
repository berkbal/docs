# JWT

JWT’lerin en buyuk avantaji ucuncu parti yazilimlarla da senkron bir sekilde calisabiliyor olmasi. Uygulama sunucusu ve ucuncu parti sunucu arasinda aktif bir baglantiya ihtiyac duymadan calisabilir.

JWT 3 Parcadan olusur, Header, Payload ve Signature.

**Payload**

Basit bir sekilde aciklamak gerekirse bir Javascript objesidir. Json formatindadir. Genelde kullanici hakkinda verileri icerir fakat boyle bir zorunluluk yoktur. 

**Header**

JWT hakkindaki bilgileri kapsayan kisim. Hangi algoritma ile hashlendigi, modeli vs bu kisimda bulunur. Dumduz bir javascript objesidir.

**Signature**

**Message Authentication Code** kismi bu kisimdadir. Sadece JWT’nin **gizli anahtarina sahip olan** kisi tarafindan uretilebilir.

**Signature Kismi Authentication icin nasil kullanilir?**

- Kullanici kullanici adini ve parolasini uygulama sunucusuna gonderir, bu genelde ayri bir sunucudur.
- Authentication islemini gerceklestiricek sunucu kullanici adi ve parola kombinasyonunu dogruladiktan sonra Payload iceren bir JWT token’i olusturur. Bu tokenin icerisine kullanicinin kimligini belirtecek json keyleri ve JWT’nin son kullanma tarihini olusturur.
- Authentication sunucusu secret key ile Header ve Payload’i imzalayarak kullanicinin tarayicisina gonderir.
- Tarayici secret key ile imzalanmis JWT yi alir ve her HTTP requestin icerisinde bu JWT yi gonderir
- Bu imzalanmis JWT kullanicinin kullanici adi ve sifre kombinasyonunun yerini alan gecici bir kullanici kimlik bilgisi olarak calisir.

**Sunucu JWT Token ile Ne Yapar?**

- HTTP Requestin icerisinde gelen JWT nin kullanicinin secret key’i ile imzalandigini dogrular. Payload kismina bakarak yapar.
- Secret key sadece Authentication sunucusunda bulunur. Ve imzalanmis JWT yi sadece dogru girilmis kullanici adi ve parola kombinasyonu yapan kisilere verir.
- Dogru bilgiler ile giris yapilinca Authentication sunucusu kullaniciya guvenerek HTTP Requestlere cevap verir. Eger kullanici guvenilmez durumda ise(yanlis kullanici adi ve sifre kombinasyonu) buna gore HTTP requeste cevap verir.
- JWT’li bir sistemin hacklenmesi icin ya kullanici adi ve sifre kombinasyonunun calinmasi ya da Authentication sunucusundan secret key’in calinmasi gerekir.

Gozuktugu uzere bir JWT’nin en onemli kismi signature kismidir. Bu dogrulama sayesinde kullaniciya her seferinde kullanici adi ve parolasini sormadan olumlu bir kullanici deneyimi ve guvenlik saglanir. Authentication sunucusu ve uygulama sunucusu genelde iki ayri sunucu olur fakat bu bir zorunluluk degildir fakat bu bir artidir. Uygulama sunucusu hafif ve guvenli, butun dogrulama islemleri de Authentication sunucusunda oldugu icin.

JWT Token’daki bahsedilen 3 parca “.” isareti ile ayrilir.