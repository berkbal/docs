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