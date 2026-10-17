# Bölüm 5: Teknoloji Yığını ve Uçtan Uca Mimari Tasarım

## 5.1 Mimari Genel Bakış ve Teknoloji Seçim Gerekçeleri
NexusCloud SaaS mimarisi, yüksek işlem hacmi, sıfır veri kaybı, çoklu kiracı güvenliği ve küresel ölçeklenebilirlik kriterlerine göre tasarlanmıştır.

```
                    ┌────────────────────────────┐
                    │      GCP CLOUD ARMOR       │ (DDoS & WAF Koruması)
                    └─────────────┬──────────────┘
                                  │
                                  ▼
                    ┌────────────────────────────┐
                    │     GCP CLOUD LOAD BALANCER│ (Managed SSL & Ingress)
                    └─────────────┬──────────────┘
                                  │
       ┌──────────────────────────┴──────────────────────────┐
       ▼                                                     ▼
┌──────────────────────────────┐              ┌──────────────────────────────┐
│  FRONTEND (NEXT.JS 15)       │              │  SPRING CLOUD API GATEWAY    │
│  App Router • Tailwind • SSR │              │  JWT Val. • Rate Limiter     │
└──────────────────────────────┘              └──────────────┬───────────────┘
                                                             │
            ┌────────────────────────────────────────────────┼────────────────────────────────┐
            ▼                                                ▼                                ▼
┌──────────────────────────────┐              ┌──────────────────────────────┐ ┌──────────────────────────────┐
│  IDENTITY & AUTH SERVICE     │              │  SUBSCRIPTION & BILLING SVC  │ │  WORKFLOW CORE ENGINE SVC    │
│  Java 21 • Spring Boot 3     │              │  Java 21 • Spring Boot 3     │ │  Java 21 • Spring Boot 3     │
└──────────────┬───────────────┘              └──────────────┬───────────────┘ └──────────────┬───────────────┘
               │                                             │                                │
               ├─────────────────────────────────────────────┴────────────────────────────────┤
               │
               ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                           VERİ VE İLETİŞİM ALTYAPISI                                        │
│                                                                                                             │
│  ┌──────────────────────┐  ┌──────────────────────┐  ┌──────────────────────┐  ┌─────────────────────────┐  │
│  │   POSTGRESQL 16      │  │      REDIS 7         │  │   ELASTICSEARCH 8    │  │      APACHE KAFKA       │  │
│  │ Cloud SQL (RLS/Flyway│  │ Memorystore L2 Cache │  │ Kiracı Denetim/Audit │  │ Olay Akışı / Partitions │  │
│  └──────────────────────┘  └──────────────────────┘  └──────────────────────┘  └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 5.2 Backend: Java 21, Spring Boot 3 ve Spring Cloud
- **Neden Java 21?**
  - **Sanal İş Parçacıkları (Virtual Threads - Project Loom):** Geleneksel OS thread'leri yerine milyonlarca hafif sanal iş parçacığıyla asenkron I/O blokajları sıfıra indirilir.
  - **Pattern Matching ve Record Sınıfları:** DDD Value Object ve Domain Event tanımları için mükemmel dil desteği.
- **Neden Spring Boot 3.x?**
  - Üretim standardı Actuator metrikleri, Micrometer Prometheus entegrasyonu ve Jakarta EE 10 standartları.
- **Spring Cloud Bileşenleri:**
  - **Spring Cloud Gateway:** Tüm gelen isteklerin karşılandığı, kiracı JWT doğrulamalarının yapıldığı ve IP/kiracı bazlı hız sınırlamasının uygulandığı merkezi kapı.
  - **Resilience4j Circuit Breaker:** Üçüncü taraf servisler (Stripe, harici webhook'lar) çöktüğünde sistemin kaskat çöküşünü (cascading failure) önleyen devre kesici.

---

## 5.3 Veritabanı ve Tüm Veri İşlemleri: PostgreSQL 16
Tüm operasyonel veriler, Google Cloud SQL üzerinde barındırılan PostgreSQL 16 kümesinde saklanır.

### Çoklu Kiracı Güvenliği (Row-Level Security - RLS):
PostgreSQL RLS politikaları ile kiracıların birbirlerinin verilerini sorgulaması engine seviyesinde imkansız hale getirilir:

```sql
-- Tablo oluşturma
CREATE TABLE subscriptions (
    id VARCHAR(64) PRIMARY KEY,
    tenant_id VARCHAR(64) NOT NULL,
    plan_tier VARCHAR(32) NOT NULL,
    price_amount NUMERIC(12, 2) NOT NULL,
    status VARCHAR(32) NOT NULL
);

-- RLS Etkinleştirme
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

-- Kiracı İzolasyon Politikası
CREATE POLICY tenant_isolation_policy ON subscriptions
    FOR ALL
    USING (tenant_id = current_setting('app.current_tenant_id', true));
```

### Şema Göçleri (Database Migrations):
Flyway kullanılarak sürüm kontrollü `V1__init.sql`, `V2__add_indexes.sql` migration dosyaları otomatik uygulanır.

---

## 5.4 Dağıtık Önbellek: Redis 7
Google Cloud Memorystore üzerinde yönetilen Redis 7 kullanılır.

### Kullanım Senaryoları:
1. **L2 Domain Önbellekleme (Cache-Aside Pattern):**
   - Kiracının aktif abonelik detayları, izinli iş akışı sayısı ve anlık durum bilgileri Redis'te saklanır (TTL: 3600 sn).
   - API isteklerinde PostgreSQL'e gitmeden %95 oranında bellekten yanıt verilir (< 2 ms).
2. **Hız Sınırlama (Rate Limiting - Token Bucket):**
   - Starter plan kiracıları saniyede maks. 20 istek; Enterprise kiracıları saniyede 1000 istek yapabilir.
3. **Dağıtık Kilit (Distributed Locking - Redlock):**
   - Aynı iş akışının eşzamanlı iki kez tetiklenmesini önlemek için kiracı bazlı dağıtık kilit mekanizması kullanılır.

---

## 5.5 Arama ve Günlük Analitiği: Elasticsearch 8.x
- **Kullanım Amacı:** PostgreSQL operasyonel transaction veritabanıdır; analitik ve adli aramalar için optimize değildir.
- **İş Akışı ve Denetim (Audit Trail) İndeksleri:**
  - Çalıştırılan her iş akışının adımları, harici API istek ve yanıtları, faturaya yansıyan kullanım detayları Elasticsearch indekslerine aktarılır.
  - Kiracı kimliği (`tenantId`) indeks anahtarı olarak tanımlanır.
- **Destek Ekibi Avantajı:** L1 ve L2 destek personeli, Elasticsearch Kibana panelleri üzerinden müşteri bir hata bildirdiğinde milisaniyeler içinde ilgili işlemi, hata mesajını ve zaman damgasını filtreleyebilir.

---

## 5.6 Olay Akışı ve Dağıtık Mesajlaşma: Apache Kafka
NexusCloud mikroservisleri arasındaki asenkron omurga **Apache Kafka**'dır.

### Kafka Mimarisi İlkeleri:
- **Topic Yapısı:** `nexus.{domain}.{event-type}.v1` (Örn: `nexus.billing.subscription-events.v1`, `nexus.workflow.execution-events.v1`).
- **Partitioning Stratejisi:** Mesaj anahtarı (Message Key) olarak kesinlikle `tenant_id` kullanılır. Böylece aynı kiracıya ait olaylar aynı Kafka partition'ında sırayla işlenir (In-order guarantee).
- **Dead-Letter Queue (DLQ):** Bir tüketici iş akışı olayını 3 denemeden sonra işleyemezse, mesaj otomatik olarak `.dlq` uzantılı hata kuyruğuna alınır ve SRE ekibine alert üretilir.

---

## 5.7 Ön Yüz Mimarisi: Next.js 15
- **Next.js 15 App Router:** Sunucu Taraflı İşleme (SSR) ve React Server Components (RSC) ile ilk yükleme süresi < 0.8 saniyeye indirilir.
- **Çoklu Kiracı Yönlendirme (Multi-Tenant Dynamic Routing):** `app/[tenant]/dashboard/page.tsx` yapısıyla kiracının URL slug'ı sunucu tarafında doğrulanır.
- **Tasarım Sistemi:** Tailwind CSS ve modern UI kütüphaneleriyle zengin görsel hiyerarşi, karanlık mod (dark mode) ve WCAG AA erişilebilirlik standartları sağlanır.

---

## 5.8 Bulut Altyapısı: Google Cloud Platform (GCP)
- **Google Kubernetes Engine (GKE):** Çoklu bölgede (multi-zone) çalışan yüksek erişilebilir Kubernetes kümesi.
- **Cloud SQL for PostgreSQL:** Otomatik replikasyon, anlık yedekleme (Point-in-Time Recovery) ve yüksek erişilebilirlik (HA).
- **GCP Secret Manager:** Veritabanı şifreleri, API anahtarları ve sertifikaların koddan tamamen ayrıştırılması.
- **Google Cloud Armor:** Kurumsal DDoS koruması, IP filtreleme ve WAF (Web Application Firewall).
