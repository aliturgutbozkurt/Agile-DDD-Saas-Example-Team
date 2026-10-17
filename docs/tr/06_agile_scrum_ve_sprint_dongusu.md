# Bölüm 6: Çevik Scrum Yaşam Döngüsü ve Sprint Süreçleri

## 6.1 Sprint 0: Altyapı, Standartlar ve Çalışma Kuralları (Working Agreements)
Projenin ilk geliştirme döngüsü başlamadan önce, ekipler 2 haftalık bir **Sprint 0** oturumu gerçekleştirmiştir.

### Sprint 0 Çıktıları:
1. **Geliştirici Ortamı Standartlaştırması:** Docker Compose ile yerel makinede tek komutla PostgreSQL, Redis, Elasticsearch ve Kafka ortamının ayağa kaldırılması (`make local-up`).
2. **Çalışma İlkeleri Sözleşmesi (Team Working Agreement):**
   - Sabah 10:00'dan önce toplantı konulmaz (Deep Work saati).
   - Açılan PR'lar en geç 4 iş saati içinde incelenir.
   - Hiçbir kod, test yazılmadan ve linter kurallarını geçmeden `main` branch'ine birleştirilemez.
   - Başarısız CI/CD pipeline'ı tüm takımın 1 numaralı önceliğidir (Stop the line kuralı).

---

## 6.2 Hazır Olma Tanımı (DoR) ve Bitti Tanımı (DoD)

### Definition of Ready (DoR - Geliştirmeye Hazır Olma Kriterleri):
Bir User Story'nin sprint içine alınabilmesi için şu şartları sağlaması zorunludur:
- [ ] İş değeri ve hedef kullanıcı persona'sı net olarak tanımlanmış olmalıdır.
- [ ] Gherkin BDD formatında en az 2 kabul kriteri (`Given`, `When`, `Then`) yazılmış olmalıdır.
- [ ] UI gerektiriyorsa Figma ekran tasarımları ve responsive varyasyonları eklenmiş olmalıdır.
- [ ] Teknik bağımlılıklar (API sözleşmesi, şema değişikliği) belirlenmiş olmalıdır.
- [ ] Ekip tarafından Planning Poker ile efor tahmini (Story Point) yapılmış olmalıdır.

### Definition of Done (DoD - Bitti Tanımı):
Bir işin tamamlandı sayılması ve canlıya sevk edilebilmesi için şu şartlar sağlanmalıdır:
- [ ] Domain katmanında birim test kapsamı (Unit Test Coverage) >= %85 olmalıdır.
- [ ] Testcontainers ile yazılmış PostgreSQL ve Kafka entegrasyon testleri başarıyla geçmelidir.
- [ ] SonarQube statik kod analizinde 0 "Security Hotspot" ve "A" kalite derecesi alınmalıdır.
- [ ] En az iki kıdemli mühendis tarafından PR onaylanmış (Approved) olmalıdır.
- [ ] API dokümantasyonu OpenAPI / Swagger üzerinde otomatik güncellenmiş olmalıdır.
- [ ] Staging ortamında otomatik E2E duman testleri (smoke tests) yeşil olmalıdır.

---

## 6.3 User Story Şablonu ve Gherkin BDD Kabul Kriterleri

### Gerçek Kullanıcı Hikayesi Örneği:
**ID:** `NEXUS-204`  
**Başlık:** Kiracının Abonelik Planını Professional Katmanına Yükseltmesi  
**Efor:** 5 Story Points  
**Ekip:** Squad Beta (Billing & Monetization)  

```gherkin
Feature: Abonelik Planı Yükseltme

  Scenario: Aktif Starter planındaki kiracının Professional plana geçmesi
    Given Kiracının kimliği "tenant-acme-corp" ve mevcut abonelik durumu "ACTIVE"
    And Mevcut planı "STARTER" seviyesinde
    When Kiracı "PROFESSIONAL" plan yükseltme talebinde bulunduğunda
    Then Abonelik durumu "ACTIVE" olarak kalmalıdır
    And Yeni plan seviyesi "PROFESSIONAL" olarak güncellenmelidir
    And "PlanUpgradedEvent" olayı Apache Kafka "nexus.billing.subscription-events.v1" konusuna yayınlanmalıdır
    And Yeni kota limiti derhal Redis önbelleğine 100000 işlem olarak yazılmalıdır
    And Kiracıya plan değişikliği onay e-postası tetiklenmelidir

  Scenario: İptal edilmiş bir aboneliğin yükseltilmeye çalışılması
    Given Kiracının mevcut abonelik durumu "CANCELLED"
    When Kiracı plan yükseltme talebinde bulunduğunda
    Then Sistem işlemi 422 Unprocessable Entity hatasıyla reddetmelidir
    And Hata mesajı "İptal edilmiş abonelikler yükseltilemez" olmalıdır
```

---

## 6.4 Efor Tahminleme: Planning Poker ve Fibonacci Serisi
Takımlar belirsizliği ve karmaşıklığı tahmin etmek için saat hesabı yerine bağıl büyüklükleri (Story Points) kullanır:
- **1-2 Puan:** Çok net, riski düşük, 1 günde tamamlanabilir rutin iş (örn: Değer nesnesi ekleme, log formatlama).
- **3-5 Puan:** Orta seviye karmaşıklıkta, veritabanı veya servis entegrasyonu içeren standart iş.
- **8 Puan:** Yüksek belirsizlik içeren, birden fazla servis veya dış sistem etkileşimi olan iş.
- **13+ Puan:** Hikaye çok büyüktür (Epic); mutlaka daha küçük hikayelere bölünmelidir.

---

## 6.5 İki Haftalık Sprint Simülasyonu: Gün Gün Takım Dinamiği

### 1. Gün (Pazartesi): Sprint Planning (Sprint Planlama)
- **Katılımcılar:** Tüm Squad üyeleri, PO, SM, Baş Mimar.
- **Akış:** PO sprint hedefini (Sprint Goal) açıklar: *"Bu sprintte kiracıların self-servis plan yükseltmelerini ve Redis kota güncellemelerini tamamlayacağız."*
- Ekip geçmiş hızına (Velocity: ortalama 38 puan) bakarak DoR şartını sağlayan hikayeleri Sprint Backlog'a çeker ve alt teknik görevlere (sub-tasks) ayırır.

### 2 - 9. Günler: Günlük Scrum (Daily Standup) ve Geliştirme Döngüsü
- **Saat:** Her sabah 09:45 (Maks. 15 dakika, ayakta).
- **3 Klasik Soru:**
  1. Dün sprint hedefine yönelik ne yaptım?
  2. Bugün ne yapacağım?
  3. İlerlememi engelleyen bir blokaj (impediment) var mı?
- **Junior Mühendis Deneyimi:** Junior mühendis, `Money` değer nesnesini geliştirdiğini, ancak döviz kuru çevriminde bir tasarım kararsızlığı yaşadığını belirtir. Kıdemli mühendis öğleden sonra 30 dakikalık bir Pair Programming oturumu ayarlar.

### 5. Gün (Cuma): Backlog Refinement (Gelecek Sprint İyileştirme)
- Ekip bir sonraki sprintte gelecek hikayeleri gözden geçirir, teknik soruları cevaplar ve kabul kriterlerini netleştirir.

### 10. Gün (Cuma): Sprint Review (Sprint Değerlendirme & Canlı Demo)
- Ekipler tamamlanan özellikleri gerçek staging ortamında tüm paydaşlara, CTO'ya ve ürün yönetimine canlı olarak sunar. Slayt kullanılmaz; çalışan yazılım gösterilir.

### 10. Gün (Cuma): Sprint Retrospective (Geriye Dönük İyileştirme)
- **Format:** Start / Stop / Continue veya 4L (Liked, Learned, Lacked, Longed for).
- Takım neyin iyi gittiğini, neyin aksadığını dürüstçe tartışır.
- **Örnek Aksiyon Kararı:** *"Kafka testlerinde Testcontainers başlatma süresi uzadı. Gelecek sprintte konteynerleri yeniden kullanmak üzere 'reusable' bayrağını aktif edeceğiz."*

---

## 6.6 Ekipler Arası Senkronizasyon: Scrum of Scrums (SoS)
Haftada iki gün (Salı ve Perşembe) tüm squad'ların Scrum Master'ları ve Baş Mimar 20 dakikalık **Scrum of Scrums** oturumunda buluşur:
- Squad 2 (Billing), Squad 3'e (Workflow) sorar: *"Yayınladığımız `PlanUpgradedEvent` şemasını tüketmeye hazır mısınız?"*
- Platform Ekibi (SRE) bildirir: *"Perşembe gecesi GKE sürüm güncellemesi yapılacak; test ortamları 10 dakika erişilemez olacak."*
- Bağımlılıklar (dependencies) görsel tahtada kırmızı iplerle eşleştirilir ve blokajlar çözülür.
