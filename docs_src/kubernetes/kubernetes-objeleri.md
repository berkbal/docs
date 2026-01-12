# Kubernetes Objeleri

Kubernetes objeleri, cluster'daki kaynakları temsil eden kalıcı varlıklardır. Kubernetes API'sini kullanarak bu objeleri oluşturabilir, güncelleyebilir ve silebilirsiniz.

Her Kubernetes objesi şu temel alanlara sahiptir:

- **apiVersion**: Kullanılacak API versiyonu
- **kind**: Objenin türü (Pod, Service, Deployment vb.)
- **metadata**: Objeyi tanımlayan bilgiler (isim, namespace, label vb.)
- **spec**: Objenin istenen durumunu belirtir

## Temel Kubernetes Objeleri

Kubernetes'te en sık kullanılan objeler:

- **Pod**: En küçük deployable birim, bir veya daha fazla container barındırır
- **Node**: Cluster'daki fiziksel veya sanal makineler
- **Namespace**: Kaynakları mantıksal olarak izole etmek için kullanılır
- **Label**: Objeleri organize etmek ve seçmek için anahtar-değer çiftleri
- **Service**: Podlara ağ erişimi sağlar
- **ConfigMap**: Uygulama yapılandırma verilerini saklar
- **Secret**: Hassas bilgileri (şifreler, token'lar) güvenli şekilde saklar
