# Swapfile Nedir?

Swapfile, Linux işletim sisteminde bellek yetersiz kaldığında kullanılmak üzere ayrılmış bir dosya alanıdır. Swap, bellek yönetimi açısından önemli bir rol oynar ve RAM yetersiz kaldığında aktif bellekte kullanılmayan verilerin disk üzerinde depolanmasını sağlar. Eğer swap alanı olmadığı zaman makinenin ram kullanımı %100'e ulaşırsa bilgisayar erişilmez hale gelecektir, donacaktır. Bunun önüne geçmek için swap alanı mutlaka oluşturulmalıdır.

Linux'ta swap, ya ayrı bir disk bölümü (swap partition) olarak ya da bir dosya olarak (swapfile) oluşturulabilir. Swapfile normal swap alanına göre daha kullanışlıdır. **Swapfile, herhangi bir dosya sistemi üzerinde, bir bölümü yeniden yapılandırmadan kolayca oluşturulabilir ve kaldırılabilir. Swap partition kullanırken disk bölümlendirmesi gerekir, bu da sistemde değişiklik yapmak istediğinizde yeniden bölümlendirme gibi zaman alıcı işlemler gerektirebilir.**

Swap partition ise, disk üzerindeki belirlenmiş bir bölüm olduğundan biraz daha hızlı olabilir çünkü dosya sistemi üzerinden değil, doğrudan donanımla çalışır. Ancak, modern sistemlerde swapfile performans kaybı genellikle minimum düzeydedir ve kullanım kolaylığı açısından swapfile tercih edilmektedir.

## Swapfile Nasıl Oluşturulur?

1. Aşağıdaki komut ile 5GB boyutunda bir swap alanı oluşturabiliriz.

```
fallocate -l 5G /swapfile
```
*Eğer fallocate komutunu kullanamıyorsanız, dd komutuyla da swap dosyası oluşturabilirsiniz.*

2. Oluşturduğumuz swap dosyasının izinlerini güvenlik nedenleri ile ayarlamamız gerekmektedir.

```
chmod 600 /swapfile
```

3. Oluşturduğumuz dosyayı swap alanı olarak biçimlendirmemiz gerekmektedir.

```
mkswap /swapfile
```

4. Oluşturduğumuz swap dosyasını etkinleştirelim

```
swapon /swapfile
```

5. Sistemi yeniden başlattığımızda swap alanının otomatik olarak mount edilmesi için /etc/fstab dosyasını düzenlemek gerekmektedir. Aşağıdaki komut ile fstab dosyasına bu ayarları gireblirsiniz

```
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

6. Swap Durumunu kontrol etmek için ```swapon --show``` veya ```free -h``` komutunu kullanabilirsiniz. Fstab dosyasını da güncellediğimiz için sistemimiz reboot olduğunda swap dosyası otomatik olarak swap alanı olarak mount edilecektir.