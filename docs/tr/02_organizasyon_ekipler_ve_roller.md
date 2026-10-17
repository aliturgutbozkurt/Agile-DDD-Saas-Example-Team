# Bölüm 2: Organizasyon Yapısı, Ekipler ve Roller

## 2.1 Team Topologies Modeli ve Ekip Organizasyonu
Nexus Digital Systems, modern kurumsal yazılım evlerinde iletişim tıkanıklıklarını önlemek ve bilişsel yükü (cognitive load) minimize etmek amacıyla **Team Topologies** modelini benimsemiştir.

Organizasyon 4 temel takım türünden oluşur:
1. **Değer Akışı Odaklı Ekipler (Stream-Aligned Squads):** Doğrudan müşteriye veya kiracıya dokunan iş değerini uçtan uca teslim eden ekipler.
2. **Platform Ekibi (Platform Team):** Altyapı, Kubernetes kümeleri, Kafka omurgası ve CI/CD otomasyonunu iç servis (Internal Developer Platform) olarak sunan ekip.
3. **Karmaşık Alt Sistem Ekibi (Complicated-Subsystem Team):** Dağıtık iş akışı motorunun durum makinesi ve matematiksel kural işleyicisini geliştiren uzman ekip.
4. **Yetkinleştirici / Kolaylaştırıcı Ekip (Enabling Team / Architecture Guild):** Yeni DDD yaklaşımlarını, güvenlik protokollerini ve performans standartlarını diğer ekiplere aktaran çekirdek ekip.

---

## 2.2 Çapraz Fonksiyonel Ekipler (Squad Yapılanması)

```
┌────────────────────────────────────────────────────────────────────────┐
│                   NEXUS DIGITAL SYSTEMS TRIBE LİDERLİĞİ                │
│       CTO  •  Baş Mimar  •  Mühendislik Müdürü (EM)  •  Agile Koç      │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
       ┌────────────────────────────┼────────────────────────────┐
       ▼                            ▼                            ▼
┌──────────────────┐       ┌──────────────────┐       ┌──────────────────┐
│     SQUAD 1      │       │     SQUAD 2      │       │     SQUAD 3      │
│  Identity & Core │       │     Billing &    │       │  Workflow Engine │
│    Multi-Tenancy │       │   Monetization   │       │   Core Platform  │
└──────────────────┘       └──────────────────┘       └──────────────────┘
       │                            │                            │
       └────────────────────────────┼────────────────────────────┘
                                    ▼
       ┌────────────────────────────┴────────────────────────────┐
       ▼                                                         ▼
┌──────────────────┐                               ┌─────────────────────┐
│     SQUAD 4      │                               │       SQUAD 5       │
│ Customer Portal  │                               │    DevOps, SRE &    │
│  & Web (Next.js) │                               │  Platform Engineers │
└──────────────────┘                               └─────────────────────┘
                                    │
                                    ▼
       ┌─────────────────────────────────────────────────────────┐
       │                MÜŞTERİ BAŞARISI VE OPERASYON            │
       │           L1 & L2 Teknik Destek Mühendisleri            │
       └─────────────────────────────────────────────────────────┘
```

### 1. Squad Alpha: Identity & Multi-Tenancy (Kimlik ve Kiracı Yönetimi)
- **Misyon:** Kiracı yaşam döngüsünü (onboarding, provizyonlama), kurumsal kimlik entegrasyonlarını (SAML 2.0, OIDC, SSO) ve rol bazlı erişim denetimini (RBAC) yönetmek.
- **Teknolojiler:** Java 21, Spring Boot 3, Spring Security, PostgreSQL, Redis.

### 2. Squad Beta: Billing & Monetization (Abonelik ve Gelir Yönetimi)
- **Misyon:** Abonelik planları, kullanım bazlı kota ölçümleme, Stripe/Iyzico ödeme geçitleri entegrasyonu, fatura kesimi ve dunning (tahsilat hatırlatma) süreçlerini yönetmek.
- **Teknolojiler:** Java 21, Spring Boot 3, PostgreSQL, Redis, Kafka Producer.

### 3. Squad Gamma: Workflow Core Engine (İş Akışı Çekirdek Motoru)
- **Misyon:** Yüksek verimli dağıtık durum makinesi, adım yürütücüler, zamanlayıcılar ve Kafka olay kuyruğu orkestrasyonunu sağlamak.
- **Teknolojiler:** Java 21, Spring Boot 3, Apache Kafka, Redis, Elasticsearch.

### 4. Squad Delta: Customer Experience & Web Squad (Kullanıcı Deneyimi)
- **Misyon:** Kiracı yönetim paneli, iş akışı görsel tasarımcısı, fatura görüntüleme arayüzü ve tasarım sistemini geliştirmek.
- **Teknolojiler:** Next.js 15, TypeScript, Tailwind CSS, React Server Components.

### 5. Squad Epsilon: DevOps, SRE & Platform Engineering
- **Misyon:** GCP üzerinde GKE kümeleri, Cloud SQL, Memorystore, Kafka altyapısı, Terraform ve GitHub Actions CI/CD boru hatlarını kesintisiz işletmek.
- **Teknolojiler:** Google Cloud Platform (GCP), Kubernetes, Helm, Terraform, GitHub Actions, Prometheus, Grafana, Jaeger.

### 6. Destek ve Canlı Operasyon Ekibi: L1 / L2 Technical Support
- **Misyon:** Canlı ortamda müşteri bildirimlerini karşılamak, log/trace incelemesi yapmak ve SLA süresi içinde eskalasyonları yönetmek.
- **Teknolojiler:** Elasticsearch, Kibana, Grafana, Jaeger, Zendesk/Jira Service Desk.

---

## 2.3 Uçtan Uca Rol Analizleri: Junior'dan CTO'ya, Analizden Desteğe

### 1. CTO (Chief Technology Officer)
- **Ana Rolü:** Teknoloji vizyonunu belirlemek, kurumsal mimari stratejilerini yönetmek ve yönetim kuruluna hesap vermek.
- **Günlük Rutinleri:**
  - GCP bulut bütçesini ve altyapı maliyet optimizasyonunu denetler (FinOps).
  - SLA (%99.95) ve güvenlik uyumluluğu (SOC 2 Type II, ISO 27001, KVKK/GDPR) metriklerini inceler.
  - Mimarlık Loncası (Architecture Guild) toplantılarını yönetir.
  - Yüksek riskli mimari kararlarda (ADR) nihai onaylayıcıdır.
- **Ürettiği Çıktılar:** Teknoloji Radarı (Tech Radar), Yıllık Altyapı Bütçe Raporu, Kurumsal Güvenlik Politikası, Şirket Mühendislik Standartları Kılavuzu.

### 2. Baş Yazılım Mimarı (Principal Software Architect)
- **Ana Rolü:** Domain-Driven Design stratejik sınırlarını korumak, servisler arası iletişim kurallarını belirlemek ve teknik borcu yönetmek.
- **Günlük Rutinleri:**
  - Bounded Context haritasını ve Context Mapping ilişkilerini günceller.
  - Kafka mesaj şemalarının (Schema Registry) ve Outbox pattern tasarımının standartlara uygunluğunu denetler.
  - Ekiplerin açtığı Mimari Karar Kayıtlarını (ADR) inceler ve onaylar.
- **Ürettiği Çıktılar:** Bounded Context Haritası, Context Map, ADR Dokümanları, Veri Akış Şemaları.

### 3. Mühendislik Müdürü (Engineering Manager - EM)
- **Ana Rolü:** Mühendislerin motivasyonunu, kariyer gelişimini, takım kapasitesini ve teslimat verimliliğini yönetmek.
- **Günlük Rutinleri:**
  - Mühendislerle haftalık 1-on-1 (birebir) görüşmeler yapar; kariyer hedeflerini gözden geçirir.
  - Sprint kapasite planlamasını Scrum Master ile koordine eder.
  - Ekipler arası insan kaynağı ve uzmanlık dengesini sağlar.
  - Junior mühendislerin kıdemli mentörlerle eşleşmesini denetler.
- **Ürettiği Çıktılar:** Mühendislik Kariyer Merdiveni Matrisi (Engineering Ladder), Çeyreklik Kapasite Raporu, Performans Değerlendirmeleri.

### 4. Ürün Sahibi (Product Owner - PO) & İş Analisti (BA)
- **Ana Rolü:** İş hedeflerini teknik gereksinimlere dönüştürmek, ürün backlog'unu yönetmek ve önceliklendirmek.
- **Günlük Rutinleri:**
  - Müşteri ve satış ekiplerinden gelen geri bildirimleri analiz eder.
  - Epik ve User Story kartlarını yazar; Gherkin BDD formatında (`Given`, `When`, `Then`) kabul kriterleri tanımlar.
  - Sprint Planning ve Backlog Refinement oturumlarını yönetir.
  - Event Storming çalıştaylarında iş uzmanı rolünü üstlenir.
- **Ürettiği Çıktılar:** Ürün Yol Haritası (Product Roadmap), Önceliklendirilmiş Product Backlog, BDD Kabul Kriterleri, Fonksiyonel Analiz Dokümanları.

### 5. Scrum Master (SM) & Çevik Koç
- **Ana Rolü:** Scrum çerçevesinin sağlıklı işletilmesini sağlamak, takım önündeki engelleri (impediments) kaldırmak ve sürekli iyileştirmeyi desteklemek.
- **Günlük Rutinleri:**
  - Günlük Scrum (Daily Standup), Sprint Planning, Review ve Retrospective seremonilerini fasilite eder.
  - Takımın Sprint Velocity ve Burn-Down grafiklerini analiz eder.
  - Ekipler arası bağımlılıkları Scrum of Scrums toplantılarında çözer.
  - Takım içi psikolojik güven ortamını korur.
- **Ürettiği Çıktılar:** Sprint Hız ve Tamamlanma Raporları, Retrospective Eylem Planları, Çevik Metrik Panoları.

### 6. Kıdemli / Lider Yazılım Mühendisi (Senior / Lead Software Engineer)
- **Ana Rolü:** Squad içindeki teknik liderliği üstlenmek, kritik DDD aggregate'lerini tasarlamak ve kod kalitesini garanti altına almak.
- **Günlük Rutinleri:**
  - Karmaşık domain agregatlarını ve domain event mekanizmalarını kodlar.
  - Açılan Pull Request'leri (PR) detaylı mimari ve kodlama standartlarına göre inceler.
  - Junior ve Mid mühendislerle düzenli Pair Programming seansları düzenler.
  - Performans darboğazlarını profiler araçlarıyla tespit eder.
- **Ürettiği Çıktılar:** Domain Aggregate Tasarımları, Kapsamlı PR İncelemeleri, Teknik Tasarım Dokümanları (TDD).

### 7. Orta Seviye Yazılım Mühendisi (Mid-Level Software Engineer)
- **Ana Rolü:** Verilen kullanıcı hikayelerini bağımsız şekilde baştan uca analiz etmek, temiz kod ve testlerle teslim etmek.
- **Günlük Rutinleri:**
  - Application Service'leri, REST controller'ları ve PostgreSQL adaptörlerini geliştirir.
  - Testcontainers kullanarak gerçekçi veritabanı ve Kafka entegrasyon testleri yazar.
  - Hata bildirimlerini inceler ve kök neden analizine katılır.
- **Ürettiği Çıktılar:** Temiz ve Test Edilmiş Servis Kodları, Unit ve Entegrasyon Test Paketleri.

### 8. Junior Yazılım Mühendisi (Junior Software Engineer)
- **Ana Rolü:** Alan Odaklı Tasarım ve çevik çalışma kültürünü öğrenmek, güvenli kod parçalarını geliştirmek ve sürekli öğrenmek.
- **Günlük Rutinleri:**
  - Değişmez Değer Nesneleri (Value Objects) ve doğrulama mantıklarını kodlar.
  - TDD prensibiyle birim testler (Unit Tests) yazar.
  - Her gün kodunu küçük, incelenebilir PR'lar halinde açar; kıdemli mühendislerden gelen yorumları inceler ve düzeltir.
  - Daily Standup'ta yaptığı işleri, yapacağı işleri ve karşılaştığı blokajları net şekilde aktarır.
- **Ürettiği Çıktılar:** Test edilmiş Değer Nesneleri, Küçük Boyutlu Kaliteli PR'lar, Birim Test Süitleri.

### 9. UI/UX Tasarımcısı (UI/UX Designer)
- **Ana Rolü:** B2B SaaS kullanıcı deneyimini mükemmelleştirmek, görsel hiyerarşi ve erişilebilir arayüzler tasarlamak.
- **Günlük Rutinleri:**
  - Figma üzerinde kullanıcı akışlarını (User Flows) ve wireframe'leri oluşturur.
  - Tasarım tokenlarını (renkler, tipografi, boşluklar) frontend ekibiyle senkronize eder.
  - Kullanılabilirlik testleri gerçekleştirir.
- **Ürettiği Çıktılar:** Figma Bileşen Kütüphanesi, Tasarım Sistemi Dokümantasyonu, Prototip ve Kullanıcı Yolculukları.

### 10. Kalite Güvence ve Test Otomasyon Mühendisi (QA / Automation Engineer)
- **Ana Rolü:** Yazılım kalitesini otomatik test süreçleriyle güvence altına almak, regresyon riskini sıfıra indirmek.
- **Günlük Rutinleri:**
  - Gherkin kabul kriterlerini Playwright test senaryolarına dönüştürür.
  - Pact ile mikroservisler arası API sözleşme (Contract) testleri yazar.
  - k6 ile API yük ve stres testlerini koşturur.
- **Ürettiği Çıktılar:** Otomatik E2E Test Süitleri, API Sözleşme Testleri, Yük Testi Raporları.

### 11. DevOps & Site Reliability Engineer (DevOps / SRE)
- **Ana Rolü:** Altyapının güvenilirliğini, ölçeklenebilirliğini ve dağıtım süreçlerinin otomasyonunu sağlamak.
- **Günlük Rutinleri:**
  - GKE küme kaynaklarını ve Horizontal Pod Autoscaler (HPA) eşiklerini optimize eder.
  - GitHub Actions CI/CD boru hatlarını denetler; derleme sürelerini düşürür.
  - Prometheus ve Grafana alarmlarını izler, hata bütçesini (Error Budget) raporlar.
  - Olay anlarında Incident Commander rolüne destek verir.
- **Ürettiği Çıktılar:** Terraform Modülleri, Helm Paketleri, CI/CD Pipeline Konfigürasyonları, Grafana Panoları.

### 12. Bilgi Güvenliği Mühendisi (SecOps / Security Engineer)
- **Ana Rolü:** Çoklu kiracı veri izolasyonunu, kimlik doğrulama güvenliğini ve uyumluluk gereksinimlerini denetlemek.
- **Günlük Rutinleri:**
  - CI/CD hattındaki Trivy ve SonarQube güvenlik tarama çıktılarını analiz eder.
  - PostgreSQL Row-Level Security politikalarını ve sızma testlerini denetler.
  - GCP Secret Manager izinlerini ve Workload Identity politikalarını inceler.
- **Ürettiği Çıktılar:** Tehdit Modelleme Raporları, Güvenlik Denetim Bulguları, Güvenli Kodlama Standartları.

### 13. L1 / L2 Teknik Destek Mühendisi (Technical Support Engineer)
- **Ana Rolü:** Müşterilerden gelen canlı sorunları ilk karşılayan, adli analizi yapan ve çözüm üreten operasyonel köprü olmak.
- **Günlük Rutinleri:**
  - Gelen destek biletlerini (tickets) SLA süresi içinde sınıflandırır.
  - Elasticsearch ve Kibana üzerinden ilgili tenant'ın işlem loglarını inceler.
  - Sorunları staging ortamında yeniden canlandırır (reproduce); gerekirse L3 mühendislik ekibine detaylı adli raporla eskalasyon açar.
- **Ürettiği Çıktılar:** Destek Çözüm Rehberleri (Runbooks), Müşteri Hata Raporları, Kök Neden Triage Dokümanları.
