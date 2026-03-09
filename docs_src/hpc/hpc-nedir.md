# Yüksek Başarımlı Hesaplama (HPC) Nedir?

HPC (**High Performance Computing**), binlerce bilgisayarın tek bir devasa sistem gibi çalışmasını sağlayan teknolojidir. Standart bilgisayarlar ile haftalarca sürecek karmaşık işlemlerin, paralel işlem gücü sayesinde birkaç saat içinde tamamlanmasını sağlar.

## Nasıl Çalışır?
HPC'nin temel taşı **Paralel İşleme** yeteneğidir. Standart bir iş istasyonu 8-16 çekirdek ile işlem yaparken, HPC cluster’ları (kümeleri) binlerce çekirdeği aynı anda senkronize ederek devasa veri setlerini işleyebilir.

---

## HPC Cluster Mimarisi ve Bileşenleri



### 1. Temel Birimler
*   **Compute Nodes (Hesaplama Düğümleri):** Asıl iş yükünün sırtlandığı, hesaplamaların yapıldığı birimlerdir.
*   **Login Node (Giriş Düğümü):** Kullanıcının sisteme bağlandığı, kodlarını derlediği ve iş yüklerini kuyruğa gönderdiği kapıdır.
*   **Head Node:** Cluster'ın "beyni"dir. Genellikle Scheduler (Slurm vb.) burada çalışır ve hangi işin hangi Compute Node'a gideceğine karar verir. Çoğu zaman kullanıcılar Login Node üzerinden bu yapıya erişir.
*   **Management Node (Yönetim Düğümü):** Sistem yöneticileri için ayrılmış birimdir. İşletim sistemi dağıtımı (provisioning), donanım izleme (monitoring), ağ yönetimi ve sistem güncellemeleri bu düğüm üzerinden yürütülür. Kullanıcı erişimine kapalıdır.

### 2. Altyapı Bileşenleri
*   **Interconnect (Yüksek Hızlı Bağlantı):** Düğümler arasındaki ultra düşük gecikmeli (InfiniBand vb.) ağdır. Verilerin mikrosaniyeler içinde iletilmesini sağlar.
*   **Parallel Storage (Paralel Depolama):** Verilerin aynı anda binlerce düğüm tarafından yüksek bant genişliğiyle okunup yazılabildiği (BeeGFS, Lustre vb.) dosya sistemleridir.

---

## HPC İş Akışı (Workflow)

Bir simülasyon veya hesaplama süreci genellikle şu adımlardan oluşur:

1.  **Erişim (Access):** Kullanıcı, `SSH` protokolü ile **Login Node**'a bağlanır.
2.  **Ortam Hazırlığı (Environment):** Gerekli mühendislik yazılımları (Ansys, Matlab, GROMACS vb.) `module load` komutuyla aktif edilir.
3.  **İş Betiği (Job Script):** İş yükü yöneticisi (örneğin **Slurm**) için kaynak taleplerini (çekirdek sayısı, bellek, süre) içeren bir script hazırlanır.
4.  **Gönderim (Submission):** Hazırlanan script, `sbatch` gibi komutlarla kuyruğa gönderilir.
5.  **Planlama (Scheduling):** Head Node üzerindeki Scheduler, kullanıcı önceliği ve kaynak müsaitliğine göre işi sıraya alır.
6.  **Yürütme (Execution):** Compute Node'lar birbirleriyle yüksek hızda haberleşerek problemi paralel olarak çözer.
7.  **Tamamlanma:** İş bittiğinde kaynaklar serbest kalır ve çıktı dosyaları kullanıcının dizinine kaydedilir.
8.  **Analiz (Post-Processing):** Oluşturulan büyük veriler analiz edilir ve görselleştirilir.