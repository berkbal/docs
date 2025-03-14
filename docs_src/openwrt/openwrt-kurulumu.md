## OpenWRT Kurulumu

### Web arayuzu ile kurulum

Cihaz cloud uzerinden yonetiliyor ama gizli bir firmware guncelleme sayfasi var. Bu sayfaya kayit olmadan erisilebilir. Eger calismazsa, cloud kaydi ile denenebilir.

Cihazda iki firmware var ve hangisinin aktif oldugunu anlamak mumkun degil. Bu yuzden once **-initramfs** surumu yuklenmeli.

#### Adimlar:

1. **OEM web arayuzune giris yap** (Bekleyerek de devam edebilirsin).
2. Gizli guncelleme sayfasina git: `http://192.168.212.1/gui/#/main/debug/firmwareupgrade`
3. Sayfa 1 dakika boyunca yuklenir (yenilemek bir pop-up gosterir ama ise yaramaz). Bir sure sonra **Upload** butonu gorunur ve aktif olur.
4. **-initramfs-kernel.bin** dosyasini yukleyip flashla.
5. Modemin yeniden baslamasini bekle ve OpenWrt arayuzune gir (`192.168.1.1`). (IP degistigi icin ethernet kablosunu cikarip takabilirsin).
6. **Go to firmware upgrade...** butonuna tikla.
7. Sayfayi asagi kaydir ve **Flash new firmware image** bolumunde **Flash Image** butonuna tikla.
8. **squashfs-sysupgrade.bin** dosyasini sec ve **Upload** butonuna bas.
9. **Keep Setting...** seceneginin isaretini kaldir.
10. **Continue** butonuna bas ve yeni firmware'i flashla.

Firmware yuklenirken LED yaklasik 10 saniye boyunca kirmizi yanar. Sonra yesil olur. Ardindan beyaz renkte hizli yanip soner, sonra yavaslar. LED beyaz sabit yaninca OpenWRT yuklenmis olur.