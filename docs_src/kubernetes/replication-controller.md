# Replication Controller

Artık önerilen bir denetleyici (controller) olmasa da, ReplicationController, mevcut durum ile yönetilen uygulamanın istenen durumunu sürekli kıyaslayarak; bir Pod'un uygulama konteynerinin istenen versiyonunun, herhangi bir anda belirli bir sayıda kopyasının (replica) çalışır durumda olmasını sağlayan karmaşık bir operatördür.

Eğer istenen sayıdan fazla Pod varsa, ReplicationController fazla olan sayıdaki Pod'u rastgele sonlandırır; eğer istenen sayıdan daha az Pod varsa, bu durumda mevcut sayı istenen sayıya ulaşana kadar ek Pod'ların oluşturulmasını talep eder. Genel olarak bir Pod'u bağımsız (tek başına) yayına almayız; çünkü bir hata sonucu sonlandığında kendi kendini yeniden başlatamaz. Bunun sebebi, Pod'un, Kubernetes'in normalde vaat ettiği o çok arzulanan 'kendi kendini iyileştirme' (self-healing) özelliğinden yoksun olmasıdır. Önerilen yöntem, Pod'ları çalıştırmak ve yönetmek için bir operatör türü kullanmaktır.

ReplicationController operatörü, replikasyonun yanı sıra uygulama güncellemelerini de destekler. Ancak, varsayılan olarak önerilen denetleyici; uygulama Pod'larının yaşam döngüsünü yönetmek için bir ReplicaSet denetleyicisi yapılandıran Deployment nesnesidir.

[ReplicaSet](replicaset.md)'den devam edilmeli.