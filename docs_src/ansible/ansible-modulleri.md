# Ansible Modülleri

Ansible yonetimi kolaylastirmak icin bazi modullere sahiptir. Bu modullerin dokumantasyonlari incelenerek yapabilecegi islemler hakkinda fikir edinilebilir.

## Apt Modulu

Ansible ile yonetilen bilgisayarlarda apt işlemleri yapmaya yarar. Aşağıdaki linkten erişilebilir.

https://docs.ansible.com/ansible/2.9/modules/apt_module.html

## Gather Facts:

Sunucular hakkında bilgi toplar ve ekrana yazdırır. Buradaki bilgileri sunucular üzerinde değişiklik yapmak için veya playbooklar yazarken kullanabiliriz. Örneğin "ansible_distribution" özelliği kurulu olan Linux'un distrosu hakkında fikir verebilir.

https://docs.ansible.com/ansible/latest/collections/ansible/builtin/gather_facts_module.html#

## Package:

Otomatik olarak işletim sisteminin paket yöneticisini kullanır. Debian için apt, CentOS için dnf kullanmaya gerek kalmaz. Playbooklarda sıkça kullanılır.

https://docs.ansible.com/ansible/latest/collections/ansible/builtin/package_module.html
