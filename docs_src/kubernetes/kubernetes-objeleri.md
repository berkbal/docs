# Kubernetes Objeleri

Kubernetes objeleri, cluster'daki kaynakları temsil eden kalıcı varlıklardır. Kubernetes API'sini kullanarak bu objeleri oluşturabilir, güncelleyebilir ve silebilirsiniz.

Her Kubernetes objesi şu temel alanlara sahiptir:

- **apiVersion**: Kullanılacak API versiyonu
- **kind**: Objenin türü (Pod, Service, Deployment vb.)
- **metadata**: Objeyi tanımlayan bilgiler (isim, namespace, label vb.)
- **spec**: Objenin istenen durumunu belirtir

## Temel Kubernetes Objeleri

- **[Pod](pod.md)**: En küçük deployable birim, bir veya daha fazla container barındırır
- **[Node](node.md)**: Cluster'daki fiziksel veya sanal makineler
- **[Namespace](namespace.md)**: Kaynakları mantıksal olarak izole etmek için kullanılır
- **[Label](label.md)**: Objeleri organize etmek ve seçmek için anahtar-değer çiftleri

## Controller Objeleri

- **[ReplicationController](replication-controller.md)**: Pod replikasyonunu yöneten eski nesil controller (artık önerilmez)
- **[ReplicaSet](replicaset.md)**: ReplicationController'ın yeni nesil hali, gelişmiş selector desteği sunar
- **[Deployment](deployment.md)**: ReplicaSet'i yöneten üst seviye obje, güncelleme stratejilerini destekler
- **[DaemonSet](daemonset.md)**: Her node üzerinde bir pod çalıştırılmasını garanti eder

## Ağ Objeleri

- **[Service](service.md)**: Podlara ağ erişimi sağlar, yük dengeleme yapar
- **[Ingress](ingress.md)**: HTTP/HTTPS trafiğini host ve path bazlı olarak servislere yönlendirir
- **[Gateway API](gateway-api.md)**: Ingress'in yeni nesil, rol bazlı ve daha esnek halefi

## Depolama Objeleri

- **[Persistent Volume](persistent-volume.md)**: Pod'lardan bağımsız depolama kaynağı ve talep mekanizması (PV/PVC)
