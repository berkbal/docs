# Bcrypt nedir?

**Bcrypt**, parolaların güvenli bir şekilde saklanmasını sağlamak amacıyla kullanılan bir şifreleme algoritmasıdır. Geleneksel şifreleme yöntemlerinden farklı olarak, bcrypt hem güvenli hem de yavaş çalışacak şekilde tasarlanmıştır. Bu, saldırganların parolaları kırma girişimlerini zorlaştırır, çünkü brute-force saldırılarıyla şifre çözmek çok uzun zaman alır.

## JavaScript İle Nasıl Kullanılır?

1. Npm üzerinden javascript projesine aşağıdaki komut ile dahil edilir.

``` 
npm install bcryptjs
```

2. Projeye dahil edilen npm paketi aşağıdaki gibi import edilir.

const bcrypt = require('bcryptjs');

3. Bu adımda yüklediğimiz paketin içerisindeki fonksiyonlar kullanılarak şifreleme işlemi gerçekleştirilir.

    - **hash:** parola olarak verilen veriyi bcrypt algoritasmı ile hashleme işlemini gerçekleştirir.

        - **password(String):** String olarak içerisine bir veri alır. Genelde kullanıcının şifrelenmemiş parolası buraya parametre olarak verilir.

        - **saltOrRounds(number | string):** Salt maliyet faktörü (genellikle 10 veya 12 gibi değerler). Bu, bcrypt'in hashing işlemi sırasında kaç tur (round) salt işlemi yapılacağını belirler. Değer ne kadar yüksekse, hashing işlemi o kadar uzun sürer ve güvenlik o kadar artar. 

        - **callback(function):** Hashleme işlemi tamamlandığında çağırılacak olan fonksiyondur. Bu fonksiyon da iki adet parametre alır.
            **- err:** Bir hata oluştuysa bu parametre hata mesajını içerir, eğer bir hata yoksa içerisindeki değer null olur.
            
            **- hash:** Hashlenmiş parola(şifre) burada yer alır.

            ```
                    const plainPassword = 'kullanicidan-alinan-parola';
                    const saltRounds = 10; // Genellikle 10 veya 12 tercih edilir

                    bcrypt.hash(plainPassword, saltRounds, function(err, hash) {
                    if (err) {
                        console.error('Hashleme hatası:', err);
                    } else {
                        console.log('Hashlenmiş şifre:', hash);
                    }
                });

            ```

            - **compare:** kullanıcı tarafından girilen plain parolayı hashlenmiş hali ile kıyaslar.

                - **plainPassword(string):** Parametre olarak karşılaştırma işlemi için kullanının şifrelenmemiş parolasını alır. 
                
                - **hashedPassword(string):** Veritabanında saklanan daha önce hashlenmiş parola bu parametre ile gönderilir. Bcrypt bu hashlenmiş parolayı(şifreyi) düz metin halindeki parola ile karşılaştırarak kontrol edecektir.(plainPassword)

                - **callback(function):** Karşılaştırma işlemi tamamlandığında çağırılacak olan callback fonksiyonudur. Bu fonksiyon da iki adet parametre alır;
                    
                    - **err:** Eğer karşılaştırma sırasında bir hata oluşursa bu paramtre hata mesajını içerir.
                    - **isMatch:** Karşılaştırma yapıldıktan sonra parolanın hashlenmiş hali ile plain text hali eşleşiyorsa true, eşleşmiyorsa false değerini alır.

                

        ```
                bcrypt.compare(plainPassword, hashedPassword, function(err, isMatch) {
                if (err) {
                    console.error('Karşılaştırma sırasında bir hata oluştu:', err);
                } else if (isMatch) {
                    console.log('Şifreler eşleşiyor!');
                } else {
                    console.log('Şifreler eşleşmiyor.');
            }
        });
        ```