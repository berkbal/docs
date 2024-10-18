# Ansible

## Ansible Nedir?

- Birden fazla makinede komut calistirmak icin kullanilir. Bu komutlara(scriptlere) playbook denir.
- Varsayilan olarak SSH kullanir.

### Kurulum ve Kullanim Adimlari

1. Asagidaki komut ile secure bir ssh key olusturulur. Key dosyasina isim verilirken full path yazilmalidir. 

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

4. Ansible adinda bir dizin oluşturulur veya hazır repo bilgisayara klonlanır.

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

## Ansible Dosya Yapısı

### Dizinler, Dosyalar ve İşlevleri

- Inventory: Ansible'in bağlanıp işlem yapacağı clientların ip adreslerinin bulunduğu dosya.
- ansible.cfg: Ansible'ın ayarlarının bulunduğu dosya. Burada inventory dosyasını ve kullanacağımız ssh keyini vs tanımlayarak ansible komutunu her çalıştırdığımızda yazacağımız komutu kısaltabiliriz.

```
berk@berk-notebook:~/Documents/repos/ansible-environment$ cat ansible.cfg 
[defaults]
inventory = inventory
private_key_file = ~/.ssh/ansible
remote_user = root
```