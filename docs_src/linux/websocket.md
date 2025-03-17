# WebSocket Nedir?

WebSocket, istemci (genellikle bir web tarayıcısı) ile sunucu arasında iki yönlü (full-duplex) ve sürekli açık bir bağlantı sağlayan bir protokoldür. HTTP’ye alternatif olarak değil, tamamlayıcı bir teknoloji olarak geliştirilmiştir ve gerçek zamanlı iletişim gerektiren uygulamalarda kullanılır.

## WebSocket'in Çalışma Mantığı

### 1. İlk Bağlantı (Handshake)

- WebSocket bağlantısı, HTTP üzerinden başlatılır.
- İstemci (tarayıcı) sunucuya WebSocket bağlantısı açmak istediğini belirten özel bir HTTP isteği (Upgrade Request) gönderir.
- Sunucu bunu kabul ederse, "101 Switching Protocols" yanıtını döndürerek WebSocket bağlantısını başlatır.

### 2. Sürekli Açık ve İki Yönlü Bağlantı
- HTTP’den farklı olarak WebSocket bağlantısı sürekli açık kalır.
- İstemci ve sunucu birbirine doğrudan veri gönderebilir (gerçek zamanlı veri akışı).
- Her yeni veri için tekrar HTTP isteği göndermeye gerek kalmaz.

### 3. Bağlantıyı Kapatma
- Tarayıcı veya sunucu bağlantıyı kapatabilir.
- Kapatma işlemi normal bir kapanış (close frame) veya hata nedeniyle olabilir.