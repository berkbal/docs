### Maxconn

Maxconn parametresi, frontend, backend veya global yapılandırmada ayarlanabilen ve aynı anda kabul edilecek maksimum bağlantı sayısını belirleyen bir ayardır. Amacı sistem kaynaklarının verimli bir şekilde kullanılmasını sağlamak ve aşırı yüklenmeyi engellemektir. Bu ayar global, frontend ve backend'de yapilabilir.

```
global
    maxconn 4096
```

## Dikkat Edilmesi Gerekenler

```ulimit``` gibi sistem ayarlarının maxconn değerini desteklemesi gerekmektedir. ```/etc/security/limits.conf``` dosyası aşağıdaki gibi editlenerek ulimit değeri kalıcı hale getirilebilir.

```
*    hard    nofile    30000071
*    soft    nofile    30000071
```