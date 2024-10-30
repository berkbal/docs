# Ansible

## Ansible Nedir?

- Birden fazla makinede komut calistirmak icin kullanilir. Bu komutlara(scriptlere) playbook denir.
- Varsayilan olarak SSH kullanir.

### Kurulum ve Kullanim Adimlari

1. Asagidaki komut ile secure bir ssh key olusturulur. Key dosyasina isim verilirken full path yazilmalidir. (Veya istege gore var olan bir key kullanılabilir.)

- Ornek: /home/berk/.ssh/ISIM seklinde isim verilebilir.

```
ssh-keygen -t ed25519 -C "ansible"
```

Asagidaki komut ile olusturulan key ansible ile kontrol edilmesi istenilen bilgisayarlara kopyalanir. root kismina kullanici adi, ip adresi kismina da kontrol edilmek istenen bilgisayarin ip adresi yazilir.

```
ssh-copy-id -i ~/.ssh/ansible.pub root@192.168.1.32
```

2. Eger keyde parola varsa her seferinde parola kullanmamak icin asagidaki komut kullanilabilir.

```
eval $(ssh_agent)
```
```ps aux``` komutunun ciktisindan ```ssh_agent```'in ```PID```'i kontrol edilir. Terminal ekrani kapandigi zaman tekrar parola girilmesi gerekebilir. Bunun icin .bashrc dosyasinda duzenlemeler yapilabilir.

3. Bilgisayara Ansible Kurulur

```
sudo apt-get install ansible -y
```

4. Ansible adinda bir dizin oluşturulur veya hazır repo bilgisayara klonlanır. Ansible ile alakalı işlemler bu dizinde yapılmalıdır.

5. inventory adında bir dosya oluşturulur ve Ansible'ın bağlanacağı ip adresleri(sunucu veya kullanıcı) bu dosyanın içerisine alt alta yazılır.

- Asagidaki komut ile baglantida sorun var mi diye kontrol edilebilir.

```
sudo ansible all --key-file ~/.ssh/ansible -i inventory -m ping
```

***Bu komutun sudo ile kullanilmasinin nedeni olusturdugumuz ssh keyinin client bilgisayarlarin root kullanicisina eklenmis olmasi.***

Ansible komutuna -u ile kullanıcı adı verilebilir.

```
ansible all --key-file ~/.ssh/ansible -i inventory -m ping -u root
```

Veya asagidaki sekilde parametreler eklenerek ansible'in root yetkisi olan kullanicinin parolasinin sormasi saglanabilir.

```
--become --ask-become-pass
```

## Modüller

Ansible yonetimi kolaylastirmak icin bazi modullere sahiptir. Bu modullerin dokumantasyonlari incelenerek yapabilecegi islemler hakkinda fikir edinilebilir.

1. Apt Modulu: Ansible ile yonetilen bilgisayarlarda apt işlemleri yapmaya yarar. Aşağıdaki linkten erişilebilir.

    - https://docs.ansible.com/ansible/2.9/modules/apt_module.html

2. Gather Facts: Sunucular hakkında bilgi toplar ve ekrana yazdırır. Buradaki bilgileri sunucular üzerinde değişiklik yapmak için veya playbooklar yazarken kullanabiliriz. Örneğin "ansible_distribution" özelliği kurulu olan Linux'un distrosu hakkında fikir verebilir.
    
    - https://docs.ansible.com/ansible/latest/collections/ansible/builtin/gather_facts_module.html#

3. Package: Otomatik olarak işletim sisteminin paket yöneticisini kullanır. Debian için apt, CentOS için dnf kullanmaya gerek kalmaz. Playbooklarda sıkça kullanılır.
    - https://docs.ansible.com/ansible/latest/collections/ansible/builtin/package_module.html

## Ansible Dosya Yapısı

### Dizinler, Dosyalar ve İşlevleri

- **Inventory:** Ansible'in bağlanıp işlem yapacağı clientların ip adreslerinin bulunduğu dosya. Ayrıca bu dosyaya ip adreslerinin yanına değişkenler tanımlanarak playbooklar içerisinde kullanılabilir.

Örnek bir Inventory dosyası:

```
192.168.1.30 apache_package=apache2 php_package=libapache2-mod-php
192.168.1.31 apache_package=apache2 php_package=libapache2-mod-php
192.168.1.32 apache_package=apache2 php_package=libapache2-mod-php
```

- **ansible.cfg:** Ansible'ın ayarlarının bulunduğu dosya. Burada inventory dosyasını ve kullanacağımız ssh keyini vs tanımlayarak ansible komutunu her çalıştırdığımızda yazacağımız komutu kısaltabiliriz.

- **Playbooks(Dizin):** YML uzantili playbooklar bu dizinde durabilir.(Zorunlu degildir fakat projenin duzenli durmasi icin gerekli olabilir.)

```
berk@berk-notebook:~/Documents/repos/ansible-environment$ cat ansible.cfg 
[defaults]
inventory = inventory
private_key_file = ~/.ssh/ansible
remote_user = root
```

# Örnekler

## Ansible ile inventory'de bulunan butun sunuculara paket kurmak

```
ansible all -m apt -a name=vim
```

apt modülünü kullanarak ```-a``` parametresi ile ```name=PAKET-ADI``` seklinde belirterek paket kurulumu yapabiliriz.

# Ansible Playbook

## Playbook Nedir?

otomasyon görevleri gerçekleştirmek için yazılan bir dosyadır. YAML formatında yazılır ve bir veya daha fazla sunucuda belirli görevleri yerine getirmek için talimatlar içerir. Playbooklar, bir dizi "play" denilen görevlerden oluşur ve her play, belirli bir hedef sunucu grubuna uygulanır. Her play içerisinde ise "task" adı verilen görevler bulunur. Task’lar ise modüller aracılığıyla çalışır, yani bir modül kullanarak bir görevi gerçekleştirmeye yönelik talimatlar verilir.

## Nasil Calistirilir?

PLaybooklarin ```./playbooks/``` dizininde oldugunu varsayarsak;

```
ansible-playbook playbooks/playbook-adi.yml
```

### Playbook Nasil Yazilir? Ornek Playbook

```
---

- hosts: all # Butun hostlarda calisacak
  become: true # Tam yetkili kullanici olarak calistirir.
  
  tasks:

  - name: Apache2 Paketini Kur
    apt: # BU task uzerinde kullanmak istedigimiz modulun adi. Paket kurulumu yapmak icin apt modulu kullanilir
    name: apache2
```

### When Kullanımı

Bazı durumlarda when condutionını kullanarak belirli durumlara göre çalışacak olan komutları/modülleri değiştirebiliriz. Aşağıdaki örnekte ansible'ın sunuculardan topladığı veriler içerisinde bulunan ```ansible_distribution``` degerini kullanarak bir koşul yazdık. Eğer bu koşul sağlanmazsa task işleme alınmayacaktır.

```
---

- hosts: all # Butun hostlarda calisacak
  become: true # Tam yetkili kullanici olarak calistirir.
  tasks:


  - name: Update Repository Index
    apt:
      update_cache: yes
    when: ansible_distribution in ["Ubuntu", "Debian"]

  - name: Apache2 Paketini Kur
    apt: # Bu task uzerinde kullanmak istedigimiz modulun adi. Paket kurulumu yapmak icin apt modulu kullanilir
     name: apache2
     state: latest
    when: ansible_distribution == "Ubuntu"
  - name: Apache'ye PHP Paketlerini Kur.
    apt:
      name: libapache2-mod-php
      state: latest
    when: ansible_distribution == "Ubuntu"
```