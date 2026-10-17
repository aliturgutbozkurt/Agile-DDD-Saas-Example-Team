#set document(
  title: "NexusCloud SaaS: DDD ve Çevik Scrum ile Kurumsal Yazılım Mühendisliği El Kitabı",
  author: "Nexus Digital Systems Mühendislik ve Mimari Kurulu",
  date: auto
)

#set page(
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.5cm, left: 2.2cm, right: 2.2cm),
  header: context {
    if counter(page).get().first() > 2 {
      text(size: 8.5pt, fill: rgb("#64748b"), font: "Helvetica Neue")[
        _NexusCloud SaaS | DDD ve Çevik Scrum ile Kurumsal Yazılım Mühendisliği Rehberi_
        #h(1fr)
        _Kurumsal Mimari Dokümantasyonu_
      ]
    }
  },
  footer: context {
    if counter(page).get().first() > 2 {
      text(size: 8.5pt, fill: rgb("#64748b"), font: "Helvetica Neue")[
        #text(weight: "bold")[Nexus Digital Systems] © 2026
        #h(1fr)
        Sayfa #counter(page).display("1")
      ]
    }
  }
)

#set text(
  font: "Helvetica Neue",
  size: 10pt,
  lang: "tr",
  spacing: 120%
)

#set par(justify: true, leading: 0.75em)
#set heading(numbering: "1.1")

#show heading.where(level: 1): it => {
  v(18pt)
  text(fill: rgb("#0f172a"), weight: "bold", size: 18pt)[#it]
  v(8pt)
}

#show heading.where(level: 2): it => {
  v(14pt)
  text(fill: rgb("#1e3a8a"), weight: "bold", size: 13pt)[#it]
  v(6pt)
}

#show heading.where(level: 3): it => {
  v(10pt)
  text(fill: rgb("#334155"), weight: "bold", size: 11pt)[#it]
  v(4pt)
}

// Callout Box Stilleri
#let callout(title: "", body, color: blue) = {
  v(6pt)
  rect(
    width: 100%,
    stroke: 0.8pt + color.darken(20%),
    fill: color.lighten(94%),
    radius: 5pt,
    inset: (x: 12pt, y: 10pt),
    [
      #text(weight: "bold", fill: color.darken(40%), size: 10.5pt)[#title] \
      #v(3pt)
      #text(size: 9.5pt, fill: rgb("#1e293b"))[#body]
    ]
  )
  v(6pt)
}

#let role_badge(role, category) = {
  v(4pt)
  rect(
    stroke: 0.5pt + rgb("#3b82f6"),
    fill: rgb("#eff6ff"),
    radius: 4pt,
    inset: (x: 8pt, y: 5pt),
    [
      #text(weight: "bold", fill: rgb("#1d4ed8"), size: 9.5pt)[#role]
      #h(6pt)
      #text(fill: rgb("#64748b"), size: 8.5pt)[(#category)]
    ]
  )
  v(4pt)
}

// =========================================================================
// KAPAK SAYFASI (COVER PAGE)
// =========================================================================
#page(header: none, footer: none, margin: 0cm)[
  #rect(
    width: 100%,
    height: 100%,
    fill: rgb("#0b1329"),
    inset: (x: 3cm, y: 3.5cm),
    [
      #v(1.5cm)
      #rect(
        fill: rgb("#1e293b"),
        radius: 4pt,
        inset: (x: 10pt, y: 6pt),
        text(fill: rgb("#38bdf8"), weight: "bold", size: 10pt, tracking: 1.5pt)[KURUMSAL SAAS MÜHENDİSLİK KILAVUZU]
      )
      
      #v(1.2cm)
      #text(fill: white, weight: "bold", size: 28pt)[
        NexusCloud SaaS:
      ] \
      #v(0.3cm)
      #text(fill: rgb("#93c5fd"), weight: "bold", size: 19pt)[
        CTO'dan Junior Mühendise, DDD ve Çevik Scrum ile Sıfırdan Zirveye Yazılım Yaşam Döngüsü
      ]
      
      #v(0.8cm)
      #line(length: 100%, stroke: 1.5pt + rgb("#38bdf8"))
      #v(0.8cm)
      
      #text(fill: rgb("#cbd5e1"), size: 10.5pt)[
        Analizden Teknik Desteğe • Çoklu Ekipler • Team Topologies \
        Java 21 • Spring Boot 3 • Spring Cloud • PostgreSQL 16 • Redis 7 \
        Elasticsearch 8 • Apache Kafka • Next.js 15 • GCP GKE • GitHub Actions
      ]
      
      #v(3.5cm)
      #grid(
        columns: (1fr, 1fr),
        gutter: 20pt,
        [
          #text(fill: rgb("#94a3b8"), size: 9.5pt)[YAZAR VE EDİTÖR KURULU] \
          #v(2pt)
          #text(fill: white, weight: "bold", size: 11pt)[Nexus Digital Systems] \
          #text(fill: rgb("#cbd5e1"), size: 9.5pt)[Mimarlık & Mühendislik Konseyi]
        ],
        [
          #text(fill: rgb("#94a3b8"), size: 9.5pt)[YAYIN TARİHİ VE SÜRÜM] \
          #v(2pt)
          #text(fill: white, weight: "bold", size: 11pt)[Ekim 2026 • v1.0 Enterprise] \
          #text(fill: rgb("#cbd5e1"), size: 9.5pt)[İstanbul & San Francisco]
        ]
      )
    ]
  )
]

// =========================================================================
// İÇİNDEKİLER & ÖNSÖZ
// =========================================================================
#pagebreak()
#v(1cm)
#text(size: 20pt, weight: "bold", fill: rgb("#0f172a"))[Önsöz ve Başlarken]
#v(0.5cm)

Bu kitap, modern bir kurumsal yazılım evinde (Software House) sıfırdan hayata geçirilen çok kiracılı (multi-tenant) bir B2B SaaS platformunun tüm mühendislik, mimari, ürün ve operasyon serüvenini ele almaktadır. 

Geleneksel yazılım dokümantasyonlarının aksine bu eser; yalnızca kod bloklarına veya soyut teorilere odaklanmaz. Bir iş analistinin (BA) ilk müşteri mülakatından, CTO'nun teknoloji radarı ve bulut bütçesi belirlemesine; bir Baş Mimarın Domain-Driven Design (DDD) ile Bounded Context sınırlarını çizmesinden, ekibe yeni katılan bir Junior Mühendisin ilk Pull Request (PR) heyecanına; DevOps mühendisinin Kubernetes ve CI/CD pipeline'larını kurmasından, canlıdaki bir Sev-1 krizinde L1/L2 destek ekibinin log ve trace adli analizine kadar her rolü yaşayan bir senaryo üzerinde detaylandırır.

#callout(title: "Hedeflenen Mimari ve Teknoloji Standartları", color: rgb("#2563eb"))[
  - *Backend Mimarisi:* Java 21, Spring Boot 3.3.x, Spring Cloud Gateway, Resilience4j Circuit Breaker.
  - *Veritabanı & Kalıcılık:* PostgreSQL 16 (Row-Level Security ve dinamik şema izolasyonu, Flyway migrations).
  - *Önbellek Katmanı:* Redis 7 (Memorystore L2 Cache-Aside ve Token Bucket hız sınırlama).
  - *Arama & Adli Analiz:* Elasticsearch 8.x (Gerçek zamanlı kiracı audit log ve olay arama).
  - *Olay Akışı (Event Streaming):* Apache Kafka (TenantId partition anahtarıyla sıralı olay işleme).
  - *Ön Yüz (Frontend):* Next.js 15 (App Router, React Server Components, TypeScript, Tailwind CSS).
  - *Bulut ve Dağıtım:* Google Cloud Platform (GCP), Google Kubernetes Engine (GKE), Google Cloud Armor.
  - *Sürekli Entegrasyon & Dağıtım:* GitHub Actions çok aşamalı güvenlik ve test boru hattı.
]

#v(1cm)
#outline(
  title: "İçindekiler Tablosu",
  depth: 2,
  indent: auto
)

// =========================================================================
// BÖLÜM 1: SENARYO VE İŞ MODELİ
// =========================================================================
#pagebreak()
= SaaS Senaryosu, Şirket Vizyonu ve B2B İş Modeli

== Nexus Digital Systems Yazılım Evi Hikayesi
*Nexus Digital Systems*, yüksek işlem hacmine sahip kurumsal şirketlere ve B2B girişimlere dijital ürünler geliştiren lider bir yazılım evidir. Şirketin kurucuları ve mühendislik liderleri, kurumsal şirketlerin iş süreçlerini otomatikleştirirken karşılaştığı üç büyük engeli gözlemlemiştir:
1. Şirket içi iş akışları (fatura onayları, üçüncü taraf API çağrıları, veri mutabakatları) parçalı ve kırılgandır.
2. Servisler arası asenkron olaylar (events) kaybolmakta veya ağ gecikmelerinde çift işlenmektedir.
3. Çoklu kiracılık (Multi-Tenancy) ve veri izolasyonu kurmak çok yüksek altyapı maliyeti gerektirmektedir.

Bu vizyonla şirket yönetimi, amiral gemisi ürünü olacak *NexusCloud SaaS* platformunu geliştirme kararı almıştır. NexusCloud, hem küresel pazarda satılacak bir ürün hem de şirketin tüm mühendislik ekipleri için altın standartları (Golden Path) belirleyen referans mimaridir.

== NexusCloud SaaS Ürün Tanımı
*NexusCloud*, B2B şirketlerin iş süreçlerini ve olay akışlarını görsel veya API tabanlı kurallarla birbirine bağlayan, kullanım bazlı faturalandırma sağlayan kurumsal bir *Akıllı İş Akışı ve Olay Orkestrasyon Platformudur*.

Platformun temel kabiliyetleri:
- *Çoklu Kiracılık (Multi-Tenancy):* Tek bir bulut kümesinde binlerce kurumsal kiracının tam veri ve kaynak izolasyonuyla barındırılması.
- *Dağıtık İş Akışı Motoru (Workflow Engine):* REST/Webhook tetikleyicileriyle çalışan, hata durumunda kendini onaran durum makineleri.
- *Dinamik Abonelik ve Gelir Yönetimi:* Starter, Professional ve Enterprise katmanlarında dinamik kota ve SLA takibi.
- *Yüksek Hacimli Olay Akışı:* Apache Kafka ile saniyede yüzbinlerce olayın mikro saniyeler düzeyinde güvenle sıralı iletimi.
- *Kurumsal Arama ve Güvenlik Denetimi:* Elasticsearch üzerinde kiracı bazlı saniyeler altı log ve denetim geçmişi arama imkânı.

== İş Modeli, Gelir Katmanları ve Sözleşmeli SLA Garantileri
Kurumsal B2B müşteriler için sistem güvenilirliği ve sözleşmeye bağlı Hizmet Seviyesi Anlaşması (SLA) en temel satın alma kriteridir.

#table(
  columns: (1.5fr, 1.2fr, 1.2fr, 1.5fr, 1.8fr),
  fill: (col, row) => if row == 0 { rgb("#1e293b") } else if calc.odd(row) { rgb("#f8fafc") } else { none },
  stroke: 0.5pt + rgb("#cbd5e1"),
  align: (col, row) => if row == 0 { center } else { left },
  inset: 7pt,
  table.header(
    text(fill: white, weight: "bold", size: 9pt)[Plan Katmanı],
    text(fill: white, weight: "bold", size: 9pt)[Aylık Ücret],
    text(fill: white, weight: "bold", size: 9pt)[SLA Garantisi],
    text(fill: white, weight: "bold", size: 9pt)[Aylık İzinli Kesinti],
    text(fill: white, weight: "bold", size: 9pt)[Destek Seviyesi]
  ),
  [Starter], [\$49 / ay], [%99.50 Uptime], [Maks. 3 saat 39 dk], [Standart E-posta (24 sa yanıt)],
  [Professional], [\$199 / ay], [%99.90 Uptime], [Maks. 43 dakika 48 sn], [Canlı Chat & E-posta (4 sa yanıt)],
  [Enterprise], [\$799+ / ay], [*%99.95 Uptime*], [*Maks. 21 dakika 54 sn*], [*7/24 Telefon & Özel Slack (< 15 dk)*]
)

#callout(title: "Hizmet Seviyesi Hedefleri (SLO / SLI)", color: rgb("#059669"))[
  - *Kullanılabilirlik (Availability SLI):* Başarılı HTTP isteklerinin toplam isteklere oranı >= %99.95.
  - *Gecikme Süresi (Latency SLI):* API uç noktalarında p99 yanıt süresi < 150 ms.
  - *Kurtarma Hedefleri:* RTO (Kurtarma Süresi) < 15 dakika, RPO (Kurtarma Noktası) < 1 dakika.
]

== Çoklu Kiracılık (Multi-Tenancy) İzolasyon Stratejisi
NexusCloud, altyapı maliyetini optimize ederken bankacılık seviyesinde veri güvenliği sunabilmek için *Hibrit Çoklu Kiracılık Mimarisi* benimsemiştir:
1. *PostgreSQL Katmanı:* Starter ve Professional müşteriler için paylaşımlı tablolar ve PostgreSQL *Row-Level Security (RLS)* kullanılır. Her sorguda kiracı ID'si zorunlu kılınır. Enterprise müşteriler için ise `tenant_{id}` adında bağımsız PostgreSQL şemaları dinamik olarak açılır.
2. *Redis Önbellek Katmanı:* Tüm anahtarlar `nexus:tenant:{tenant_id}:{aggregate}:{id}` ad alanıyla yalıtılır.
3. *Apache Kafka Katmanı:* `tenant_id` mesaj anahtarı (record key) yapılarak kiracının tüm olayları aynı Kafka partition'ında sıralı işlenir.

// =========================================================================
// BÖLÜM 2: ORGANİZASYON VE ROLLER
// =========================================================================
#pagebreak()
= Organizasyon Yapısı, Ekipler ve Roller

== Team Topologies ve Çapraz Fonksiyonel Squad'lar
Yazılım evinde iletişim karmaşasını önlemek için *Team Topologies* çerçevesi uygulanır. Şirket bünyesinde 5 otonom Squad ve 1 Destek Operasyonu bulunmaktadır:

1. *Squad Alpha (Identity & Multi-Tenancy):* Kiracı yaşam döngüsü, SSO/SAML entegrasyonları ve RBAC yetkilendirmesi.
2. *Squad Beta (Billing & Monetization):* Abonelik planları, kota ölçümleme, Stripe entegrasyonu ve dunning süreçleri.
3. *Squad Gamma (Workflow Core Engine):* Dağıtık durum makinesi, adım çalıştırıcılar ve Kafka olay kuyruğu orkestrasyonu.
4. *Squad Delta (Customer Experience & Web):* Next.js 15 tabanlı kiracı portalı, iş akışı görsel tasarımcısı ve UI tasarım sistemi.
5. *Squad Epsilon (DevOps, SRE & Platform):* GCP GKE kümesi, Cloud SQL, Kafka altyapısı, Terraform ve GitHub Actions CI/CD boru hatları.
6. *Müşteri Başarısı ve Canlı Destek (L1 / L2):* Canlı ortam bilet triyajı, Elasticsearch log araştırması ve L3 eskalasyonu.

== Uçtan Uca Rol Detayları ve Günlük Rutinler

#role_badge("Chief Technology Officer (CTO)", "Yönetici Liderlik")
- *Sorumluluklar:* Teknoloji vizyonunu çizmek, bulut bütçesini (FinOps) optimize etmek, kurumsal SLA (%99.95) ve SOC 2 uyumluluğunu yönetmek.
- *Günlük Rutini:* Sabah ilk iş Prometheus ve Cloud Billing panolarını inceler; Mimarlık Loncası'na başkanlık eder; kritik Mimari Karar Kayıtlarını (ADR) onaylar.

#role_badge("Baş Yazılım Mimarı (Principal Architect)", "Mimari & Sistem Tasarımı")
- *Sorumluluklar:* DDD stratejik sınırlarını belirlemek, Bounded Context haritasını güncellemek ve Kafka şema standartlarını korumak.
- *Günlük Rutini:* Ekiplerin kod yapılarını inceler; servisler arası Anti-Corruption Layer (ACL) adaptörlerini doğrular; karmaşık teknik spike'ları yürütür.

#role_badge("Mühendislik Müdürü (Engineering Manager)", "İnsan Kaynağı & Süreç")
- *Sorumluluklar:* Mühendislerin kariyer merdivenini yönetmek, 1-on-1 görüşmeleri yapmak, takım kapasitesini dengelemek ve engelleri kaldırmak.

#role_badge("Ürün Sahibi (PO) & İş Analisti (BA)", "Ürün Yönetimi & Analiz")
- *Sorumluluklar:* Müşteri gereksinimlerini Epik ve User Story'lere dönüştürmek, Gherkin BDD (`Given-When-Then`) kabul kriterlerini yazmak, Event Storming oturumlarını yönetmek.

#role_badge("Scrum Master (SM) & Çevik Koç", "Süreç Kolaylaştırıcısı")
- *Sorumluluklar:* Scrum seremonilerini yönetmek, velocity ve burn-down grafiklerini izlemek, ekipler arası bağımlılıkları Scrum of Scrums'ta çözmek.

#role_badge("Kıdemli / Lider Yazılım Mühendisi (Senior / Lead)", "Teknik Liderlik & Kodlama")
- *Sorumluluklar:* Rich Domain Aggregate'lerini tasarlamak, kod incelemelerinde (PR Review) titiz geri bildirim vermek, Junior mühendislerle Pair Programming yapmak.

#role_badge("Junior Yazılım Mühendisi", "Geliştirme & Öğrenme")
- *Sorumluluklar:* Değişmez Değer Nesnelerini (Value Objects) geliştirmek, TDD ile birim testler yazmak, Daily Standup'ta şeffaf iletişim kurmak ve PR yorumlarını hızla uygulamak.

#role_badge("DevOps & SRE Mühendisi", "Altyapı & Gözlemlenebilirlik")
- *Sorumluluklar:* GKE kümelerini, Terraform IaC modüllerini, GitHub Actions CI/CD boru hatlarını ve Prometheus/Grafana alarmlarını kesintisiz işletmek.

#role_badge("L1 / L2 Teknik Destek Mühendisi", "Operasyon & Adli Analiz")
- *Sorumluluklar:* Canlı müşteri bildirimlerini karşılamak, Elasticsearch üzerinden logları süzmek, runbook'ları uygulamak ve Sev-1 krizlerinde L3 nöbetçisini uyandırmak.

// =========================================================================
// BÖLÜM 3: DDD STRATEJİK TASARIM
// =========================================================================
#pagebreak()
= Alan Odaklı Tasarım (DDD) Stratejik Tasarım ve Event Storming

== Problem Alanı vs. Çözüm Alanı
Mimarlık ekibi, platformu üç ana alt alana (subdomain) ayırmıştır:
- *Core Domain (İş Akışı Orkestrasyonu):* Şirketin pazar rekabetinde fark yarattığı çekirdek mekanizmadır. Tüm inovatif mühendislik buraya yoğunlaştırılır.
- *Supporting Subdomains (Abonelik ve Çoklu Kiracılık):* Çekirdek alanın çalışması ve para kazanması için zorunludur; şirket içi geliştirilir ancak basit tutulur.
- *Generic Subdomains (Kimlik, Bildirim, Denetim):* Pazardaki standart kütüphaneler ve açık kaynak araçlarla (Spring Security, SendGrid, ELK) çözülür.

== Event Storming Çalıştayı ve Olay Zaman Çizelgesi
Sprint 0'da tüm paydaşlar 3 günlük Event Storming çalıştayında bir araya gelmiştir:
1. `TenantRegistered` ➔ `TrialSubscriptionProvisioned` ➔ `DefaultWorkflowCreated`
2. `WorkflowTriggerReceived` ➔ `TenantQuotaChecked` ➔ `WorkflowExecutionStarted`
3. `StepExecutedSuccessfully` ➔ `WorkflowExecutionCompleted` ➔ `ExecutionMetered`
4. `BillingCycleEnded` ➔ `InvoiceGenerated` ➔ `PaymentChargedViaStripe` ➔ `SubscriptionRenewed`
5. *(Kriz Senaryosu)*: `PaymentFailed` ➔ `GracePeriodStarted` ➔ `DunningEmailSent` ➔ `SubscriptionSuspended`

== Ortak Dil Sözlüğü (Ubiquitous Language)
#table(
  columns: (1.5fr, 1.5fr, 1.5fr, 3.5fr),
  fill: (col, row) => if row == 0 { rgb("#1e293b") } else if calc.odd(row) { rgb("#f8fafc") } else { none },
  stroke: 0.5pt + rgb("#cbd5e1"),
  inset: 6pt,
  table.header(
    text(fill: white, weight: "bold", size: 8.5pt)[Terim (TR)],
    text(fill: white, weight: "bold", size: 8.5pt)[Terim (EN)],
    text(fill: white, weight: "bold", size: 8.5pt)[Bağlam],
    text(fill: white, weight: "bold", size: 8.5pt)[Tanım ve İş Kuralı]
  ),
  [Kiracı], [Tenant], [Identity], [Platformda bağımsız veritabanı izolasyonuna sahip müşteri organizasyonu.],
  [Abonelik], [Subscription], [Billing], [Belirli bir plan katmanı ve kota sınırları dahilinde geçerli sözleşme.],
  [Plan Seviyesi], [Plan Tier], [Billing], [Starter, Professional veya Enterprise katmanlarından biri.],
  [İş Akışı], [Workflow], [Workflow], [Sıralı veya koşullu adımlardan oluşan yürütülebilir durum makinesi.],
  [Yürütme], [Execution], [Workflow], [Bir iş akışının tetiklenerek somut bir işlem örneği oluşturması.],
  [Olay Yolu], [Outbox], [Shared Kernel], [PostgreSQL ve Kafka arasında çifte yazma hatasını önleyen atomik tablo.]
)

== Sınırlandırılmış Bağlamlar (Bounded Contexts) ve Context Map
NexusCloud servisleri arasında 4 temel ilişki modeli tanımlanmıştır:
- *Upstream / Downstream (Müşteri - Tedarikçi):* Identity Context üst akış, Subscription Context alt akıştır.
- *Anti-Corruption Layer (ACL):* Workflow Engine, Billing servisinden gelen ham veri modellerini doğrudan kabul etmez; kendi iç `QuotaPolicy` nesnesine dönüştüren bir tercüme katmanı (ACL) kullanır.
- *Open Host Service (OHS):* Identity servisi, tüm tüketicilere JSON-Schema ile yayımlanmış olaylar sunar.

// =========================================================================
// BÖLÜM 4: DDD TAKTİKSEL TASARIM
// =========================================================================
#pagebreak()
= Alan Odaklı Tasarım (DDD) Taktiksel Tasarım ve Mimari İlkeler

== Altıgen Mimari (Hexagonal / Ports & Adapters)
NexusCloud backend mikroservislerinde iş mantığı (Domain), veritabanı sürücülerinden, web controller'larından ve Kafka kütüphanelerinden tamamen bağımsızdır:
- *Driving Ports (Sürücü Portlar):* Dış dünyadan gelen HTTP ve Kafka olaylarını kabul eden uygulama servisleri.
- *Core Domain:* Varlıklar, Değer Nesneleri, Kök Nesneler ve Olaylar.
- *Driven Ports (Sürülen Portlar):* Veritabanı ve kuyruk işlemlerini soyutlayan arayüzler (`ISubscriptionRepository`).
- *Secondary Adapters (Adaptörler):* Spring Data JPA, PostgreSQL JDBC, RedisTemplate ve KafkaTemplate implementasyonları.

== Değer Nesneleri (Value Objects)
- *Kimliksizlik:* Kimlikleri (ID) yoktur; sadece sahip oldukları değerlerle tanımlanırlar.
- *Değişmezlik (Immutability):* Java `record` veya `final class` olarak kodlanırlar. Bir kez yaratıldıktan sonra durumu değiştirilemez.
- *Örnekler:* `TenantId` (DNS slug ve UUID doğrulamalı), `Money` (negatif olamaz, para birimi güvenliği), `SubscriptionPlan` (katman, fiyat, SLA eşiği).

== Kök Nesneler (Aggregate Roots) ve İş Kuralları (Invariants)
Bir Aggregate, işlem tutarlılığı sınırıdır (Transactional Consistency Boundary):
- `SubscriptionAggregate` iş kuralları:
  1. İptal edilmiş (`CANCELLED`) bir abonelik yenilenemez, yükseltilemez ve askıya alınamaz.
  2. Bir kiracının aynı anda birden fazla aktif aboneliği bulunamaz.
  3. Yenileme işleminde dönem bitiş tarihi (`periodEnd`) daima başlangıç tarihinden (`periodStart`) ileri bir tarih olmalıdır.

== Çifte Yazma (Dual-Write) Problemi ve Transactional Outbox Pattern
Veritabanına yazıp aynı anda Kafka'ya mesaj atarken ağ koptuğunda veri tutarsızlığı oluşur. NexusCloud bu problemi *Transactional Outbox Pattern* ile çözer:
1. Abonelik tablosu güncellenirken aynı PostgreSQL transaction'ı içinde `subscription_outbox_events` tablosuna domain event JSON olarak kaydedilir.
2. Arka plan Debezium CDC veya Outbox Poller işlemi bu kayıtları okuyup Kafka'ya iletir.
3. Böylece %100 en az bir kez iletim (At-least-once delivery) garantisi sağlanır; hiçbir fatura veya provizyon olayı kaybolmaz.

// =========================================================================
// BÖLÜM 5: TEKNOLOJİ YIĞINI MİMARİSİ
// =========================================================================
#pagebreak()
= Teknoloji Yığını ve Uçtan Uca Mimari Tasarım

== Backend: Java 21, Spring Boot 3 ve Spring Cloud
- *Java 21 Sanal İş Parçacıkları (Virtual Threads):* Bloklanan I/O çağrılarında geleneksel thread havuzunu tüketmeden yüzbinlerce eşzamanlı HTTP ve Kafka isteğini mikro bellek ayak iziyle yönetir.
- *Spring Cloud Gateway:* Merkezi giriş kapısı. Tüm kiracı JWT doğrulamaları, IP/Kiracı hız sınırlamaları ve yönlendirmeler burada yapılır.
- *Resilience4j Circuit Breaker:* Stripe veya üçüncü taraf webhook'lar yanıt vermediğinde sistemin kaskat çöküşünü önler.

== Veritabanı: PostgreSQL 16 (Row-Level Security & Flyway)
PostgreSQL motorunda RLS politikası uygulanarak kiracıların birbirlerinin verisine erişmesi donanımsal düzeyde engellenir:
```sql
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation_policy ON subscriptions
    FOR ALL
    USING (tenant_id = current_setting('app.current_tenant_id', true));
```
Tüm şema değişiklikleri Flyway migration dosyalarıyla versiyonlanır.

== Önbellek: Redis 7 (Google Cloud Memorystore)
- *Cache-Aside Deseni:* Kiracının aktif aboneliği ve kota bilgileri Redis'te saklanır (TTL: 3600 sn). Okuma isteklerinin %94'ü veritabanına uğramadan 2 ms altında karşılanır.
- *Token Bucket Hız Sınırlama:* Kiracının API limitini aşması durumunda istekler anında 429 Too Many Requests ile durdurulur.

== Arama ve Günlük Analitiği: Elasticsearch 8.x
Çalıştırılan tüm iş akışlarının adım logları, hata detayları ve faturalama denetim izleri Elasticsearch'e akar. L1 ve L2 destek mühendisleri, müşterinin sağladığı `tenantId` veya `traceId` ile Kibana panellerinden saniyeler altında adli analiz yapar.

== Olay Akışı: Apache Kafka
- *Topic Formatı:* `nexus.{domain}.{event-type}.v1`.
- *TenantId Partitioning:* Mesaj anahtarı olarak kiracı ID'si atanır; kiracıya ait tüm olaylar aynı partition'da sıralı işlenir.
- *Dead-Letter Queue (DLQ):* 3 denemeden sonra işlenemeyen zehirli mesajlar `.dlq` konusuna aktarılarak alarmlar tetiklenir.

== Ön Yüz: Next.js 15
Next.js 15 App Router ve React Server Components (RSC) ile geliştirilen portal, dinamik `app/[tenant]/dashboard` yönlendirmesiyle kiracıyı sunucu tarafında doğrular. Tailwind CSS ile WCAG AA erişilebilirlik standartlarında modern ve hızlı bir arayüz sunar.

== Bulut: Google Cloud Platform (GCP) & Kubernetes (GKE)
- *GKE Kümesi:* us-central1 bölgesinde çok bölgeli (multi-zone) çalışan pod havuzları.
- *Google Cloud Armor:* Kurumsal WAF ve DDoS koruması.
- *GCP Secret Manager:* Sıfır sabit şifre ilkesi (Zero-hardcoded secrets).

// =========================================================================
// BÖLÜM 6: ÇEVİK SCRUM VE SPRINT SÜREÇLERİ
// =========================================================================
#pagebreak()
= Çevik Scrum Yaşam Döngüsü ve Sprint Süreçleri

== Sprint 0 ve Çalışma İlkeleri (Working Agreements)
- Sabah 10:00'dan önce toplantı konulmaz (Deep Work).
- PR incelemeleri en geç 4 iş saati içinde tamamlanır.
- Kırmızı CI/CD hattı tüm takımın acil ortak önceliğidir (Stop the line).

== Definition of Ready (DoR) ve Definition of Done (DoD)
#grid(
  columns: (1fr, 1fr),
  gutter: 15pt,
  [
    #callout(title: "Definition of Ready (DoR)", color: rgb("#2563eb"))[
      - İş değeri ve hedef kullanıcı persona'sı net olmalıdır.
      - Gherkin formatında en az 2 kabul kriteri yazılmış olmalıdır.
      - Figma ekran tasarımları tamamlanmış olmalıdır.
      - Planning Poker ile efor puanı (Story Point) verilmiş olmalıdır.
    ]
  ],
  [
    #callout(title: "Definition of Done (DoD)", color: rgb("#059669"))[
      - Domain katmanında test kapsamı >= %85 olmalıdır.
      - Testcontainers PostgreSQL ve Kafka testleri geçmelidir.
      - SonarQube analizi yeşil olmalıdır.
      - En az 2 kıdemli mühendis onay vermiş olmalıdır.
      - Staging ortamında duman testleri başarılı olmalıdır.
    ]
  ]
)

== User Story ve Gherkin BDD Kabul Kriterleri
```gherkin
Feature: Abonelik Planı Yükseltme
  Scenario: Starter planındaki kiracının Professional plana geçmesi
    Given Kiracının kimliği "tenant-acme-corp" ve durumu "ACTIVE"
    And Mevcut planı "STARTER" seviyesinde
    When Kiracı "PROFESSIONAL" plan yükseltme talebinde bulunduğunda
    Then Abonelik durumu "ACTIVE" kalmalı ve yeni plan "PROFESSIONAL" olmalıdır
    And "PlanUpgradedEvent" olayı Kafka "nexus.billing.subscription-events.v1" konusuna atılmalıdır
    And Yeni kota limiti 100,000 işlem olarak anında Redis'e yazılmalıdır
```

== İki Haftalık Sprint Rutini ve Scrum of Scrums
- *Pazartesi:* Sprint Planning (Kapasite belirleme, Sprint Hedefi açıklaması).
- *Hergün (09:45):* 15 dakikalık ayakta Daily Standup.
- *Cuma (5. Gün):* Backlog Refinement.
- *Cuma (10. Gün):* Sprint Review (Canlı demo) ve Retrospective (4L metodu).
- *Salı & Perşembe:* Ekipler arası bağımlılıkları çözmek için 20 dakikalık Scrum of Scrums (SoS).

// =========================================================================
// BÖLÜM 7: DEVOPS, GCP, KUBERNETES VE CI/CD
// =========================================================================
#pagebreak()
= DevOps, GCP, Kubernetes ve CI/CD Pipeline Mimarisi

== Google Kubernetes Engine (GKE) Küme Tasarımı
- *Workload Identity Federation:* Kubernetes Pod'larının GCP kaynaklarına erişimi için sabit JSON servis hesabı anahtarı kullanılmaz; OIDC tabanlı dinamik kimlik kullanılır.
- *Horizontal Pod Autoscaler (HPA):* CPU > %70 veya bellek > %80 olduğunda Pod sayısı 3'ten 15'e otomatik yükseltilir.
- *Kesintisiz Dağıtım (Zero-Downtime Rolling Update):* `maxSurge: 1` ve `maxUnavailable: 0` ile yeni Pod sağlıklı yanıt vermeden eski Pod kapatılmaz.

== GitHub Actions Çok Aşamalı Pipeline
1. *Statik Analiz:* Checkstyle, SonarQube Quality Gate ve Trivy güvenlik taraması.
2. *Otomatik Test:* Testcontainers ile izole PostgreSQL 16 ve Kafka konteynerleri üzerinde gerçek testler.
3. *Paketleme:* Alpine Temurin 21 ile çok aşamalı (multi-stage) Docker derlemesi.
4. *Dağıtım:* Google Artifact Registry'ye itme ve GKE üzerinde `kubectl rollout` tetikleme.

== Gözlemlenebilirlik (Observability Üçgeni) ve Hata Bütçesi
- *Prometheus & Grafana:* HTTP gecikmesi (p99 < 150 ms), Kafka lag ve HikariCP havuzu takibi.
- *JSON Loglama & Elasticsearch:* Standart JSON formatında `traceId` ve `tenantId` etiketli loglar.
- *OpenTelemetry & Jaeger:* Uçtan uca dağıtık izleme.
- *Hata Bütçesi (Error Budget):* %99.95 SLA aylık maksimum 21.6 dakika kesintiye izin verir. Bütçenin %80'i tükendiğinde yeni özellik sevkiyatı dondurulur; sadece dayanıklılık geliştirilir.

// =========================================================================
// BÖLÜM 8: QA, TEST PİRAMİDİ VE GÜVENLİK
// =========================================================================
#pagebreak()
= Kalite Güvencesi (QA), Test Piramidi ve Güvenlik

== Test Piramidi Uygulaması
- *Birim Testler (%50):* JUnit 5 ve Mockito ile mikro saniyeler seviyesinde çalışan domain kuralları.
- *Entegrasyon Testleri (%30):* Testcontainers ile gerçek PostgreSQL ve Kafka üzerinde SQL ve mesaj akışı doğrulaması.
- *Sözleşme Testleri (%15):* Pact ile frontend ve backend API sözleşmelerinin kırılmaması garantisi.
- *Uçtan Uca Testler (%5):* Playwright ile gerçek tarayıcı üzerinde kayıt ve ödeme akışları.

== Kurumsal Bilgi Güvenliği (SecOps)
- *OWASP Top 10 Savunması:* Hibernate JPA parametreli sorgularıyla SQL injection imkansız kılınır.
- *Kiracı İzolasyon Testleri:* Her sprintte A kiracısının token'ı ile B kiracısının verisine erişim denemeleri koşularak 403 Forbidden doğrulanır.
- *Sıfır Sabit Şifre:* Git reposunda hiçbir gizli anahtar tutulmaz; sırlar Google Secret Manager'dan runtime'da çekilir.

// =========================================================================
// BÖLÜM 9: TEKNİK DESTEK VE INCIDENT YÖNETİMİ
// =========================================================================
#pagebreak()
= Teknik Destek (L1/L2), Olay (Incident) ve Kriz Yönetimi

== Destek Kademeleri ve Eskalasyon Protokolü
- *L1 Destek (Helpdesk):* İlk 15 dakika içinde bileti sınıflandırır, ilk yanıtı verir, standart runbook'u uygular.
- *L2 Destek:* 30 dakika içinde Elasticsearch loglarını inceler, staging'de hatayı reproduse eder.
- *L3 Nöbetçi Mühendis (On-Call SRE):* Sev-1 krizlerinde 15 dakika içinde War Room'a katılır ve canlı müdahale yapar.

== Canlı Kriz Simülasyonu: INC-4819 (Kafka Tüketici Çökmesi)
- *Olay:* Stripe'tan gelen anlık 12,000 webhook çağrısı sonucu bellek yetersizliği ile Pod'lar CrashLoopBackOff'a düşer; Kafka lag 15,000 mesaja fırlar.
- *Müdahale:* Incident Commander atanır, War Room açılır; bellek 2048Mi'ye çekilip pod sayısı 10'a çıkarılır. 28 dakika içinde lag sıfırlanır ve kotalar eşitlenir.
- *5 Neden Analizi (5 Whys):* HPA'nın Kafka lag metriğine bağlı olmadığı tespit edilir. KEDA kurularak gelecekteki benzer patlamalar otomatik ölçeklenmeye bağlanır.
- *Suçlamasız Rapor (Blameless Post-Mortem):* Kişiler değil, sistem açıkları hedef alınarak önleyici aksiyonlar belirlenir.

// =========================================================================
// BÖLÜM 10: JUNIOR MÜHENDİS SAHA REHBERİ
// =========================================================================
#pagebreak()
= Junior Mühendisin Saha Rehberi ve Kariyer Yolculuğu

== İlk 30-60-90 Gün Onboarding Yol Haritası
- *İlk 30 Gün:* Docker Compose ile yerel ortamı kurma, ortak dili kavrama, ilk Value Object'i geliştirip ilk PR'ı birleştirme.
- *31 - 60 Gün:* Bağımsız bir User Story tamamlama, Testcontainers ile entegrasyon testi yazma, haftalık 2 seans Senior ile Pair Programming yapma.
- *61 - 90 Gün:* Kafka tüketicisi veya Redis önbellek mekanizması geliştirme, canlı krizde L2/L3 nöbetçisini gölge (shadow) olarak izleme.

== Bir User Story'yi Koda Dönüştürme Adımları
1. Kabul kriterlerini (`Given-When-Then`) dikkatle oku.
2. TDD ile önce başarısız JUnit testini yaz (Red).
3. Testi geçecek en sade kodu yaz (Green).
4. Kodu DDD kurallarına göre temizle ve refactor et.
5. Küçük ve temiz bir PR aç (< 250 satır).

== Senior Code Review Yorumlarını Karşılama Sanatı
- Senior mühendisin yorumları kişisel bir eleştiri değil, mesleki bir gelişim hediyesidir.
- Anlaşılmayan her detayı *"Neden bu yaklaşımı tercih etmeliyiz?"* sorusuyla öğrenme fırsatına çevir.
- 15 Dakika Kuralı: Bir problemle karşılaştığında 15 dakika logları ve kod geçmişini araştır; çözemezsen kıdemli mühendise denediğin adımlarla birlikte soru sor.

== Kariyer Merdiveni: Junior'dan Senior ve Mimarlığa
- *Junior:* Verilen rehberlikle kaliteli kod yazar, öğrenmeye açıktır.
- *Mid-Level:* Bağımsız hikaye teslim eder, karmaşık entegrasyonları çözer.
- *Senior / Lead:* Mimari aggregate'leri tasarlar, belirsizlikleri yönetir, junior mühendisleri yetiştirir.
- *Principal Architect / CTO:* Şirket çapında teknoloji standartlarını ve vizyonu belirler.
