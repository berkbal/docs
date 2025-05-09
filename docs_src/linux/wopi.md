## WOPI (Web Application Open Platform Interface) Nedir?

**WOPI**, Microsoft tarafından geliştirilmiş, bir **dosya barındırma hizmeti (örneğin: Nextcloud)** ile bir **web tabanlı belge düzenleyici (örneğin: Collabora Online veya OnlyOffice)** arasında güvenli iletişimi sağlayan bir **RESTful API protokolüdür**.

### Temel Amaç:
- Kullanıcıların web tabanlı arayüzler üzerinden dosya görüntüleme ve düzenleme işlemlerini güvenli bir şekilde yapabilmesini sağlamak.
- Belge sunucusu (Nextcloud) ile düzenleme motoru (Collabora) arasındaki **belge erişimini ve işlemlerini standardize etmek**.

## WOPI Bileşenleri

### 1. **WOPI Host**
- Örn: **Nextcloud**
- Belgeleri fiziksel olarak barındıran ve WOPI API'yi sunan sunucu.
- Sorumlulukları:
  - Token doğrulama
  - Dosya içeriği sağlama (`/wopi/files/<id>/contents`)
  - Metadata sağlama (`/wopi/files/<id>`)
  - Kaydetme işlemleri

### 🧠 2. **WOPI Client**
- Örn: **Collabora Online**
- Kullanıcıya belge düzenleme arayüzünü sunan uygulama.
- Tarayıcı üzerinden iframe ile çalışır.
- WOPI host'tan belgeyi alır, işler, render eder, kullanıcı etkileşimini yönetir.

---

## 🔄 Tipik İletişim Süreci (WOPI ile)

1. **Nextcloud**, istemciden bir belge düzenleme isteği alır.
2. Nextcloud, bir **WOPI Access Token** üretir ve Collabora Online için uygun bir iframe URL'si oluşturur.
3. Tarayıcı, bu iframe üzerinden doğrudan **Collabora sunucusuna bağlanır**.
4. Collabora, belge içeriğini almak için **Nextcloud’un WOPI API'sine** istek gönderir:
   - `GET /wopi/files/<file_id>`
   - `GET /wopi/files/<file_id>/contents`
5. Kullanıcı belgeyi düzenledikçe, Collabora:
   - `POST /wopi/files/<file_id>/contents` ile belgeyi kaydeder.

---

## 🛡️ Güvenlik Unsurları

- WOPI erişimi sadece geçici, **zaman kısıtlamalı access token**'larla mümkündür.
- Collabora sadece **belirtilmiş domainlerden gelen iframe isteklerine** izin verir (örneğin: `domain=nextcloud\\.example\\.com`).
- İstemciler Collabora’ya **doğrudan HTTPS bağlantısı kurar**, Collabora da sadece valid WOPI token ile belgeleri işleme alır.

---

## ⚠️ Kritik Nokta (Senin Sorunun Cevabı):

**WOPI mimarisinde tarayıcı (istemci), Collabora sunucusuna doğrudan bağlanmak zorundadır.**  
Bu, protokolün tasarımı gereğidir çünkü iframe içinde Collabora UI doğrudan çalışır ve istemci tarayıcısı belge düzenleme motoru ile etkileşime girer.

### → Yani: 
**“Tüm trafik Nextcloud üzerinden geçsin, istemciler Collabora sunucusuna doğrudan bağlanmasın.”** gibi bir yapı, **WOPI standardı ile uyumlu değildir.**

---

## 📚 Resmi Kaynaklar

- [Microsoft WOPI Specification (v12.2)](https://learn.microsoft.com/en-us/microsoft-365/cloud-storage-partner-program/rest-protocol?view=o365-worldwide)
- [Collabora WOPI Overview (GitHub)](https://github.com/CollaboraOnline/online/blob/master/WOPISupport.md)
- [Nextcloud Collabora Integration Docs](https://nextcloud.com/collaboraonline/)

---

İstersen bu bilgileri, patronuna sunmak üzere PDF veya e-posta formatında teknik bir özet olarak hazırlayabilirim.