# Bölüm 8: Kalite Güvencesi (QA), Test Piramidi ve Kurumsal Güvenlik

## 8.1 Test Piramidi Stratejisi
NexusCloud platformunda kalite güvencesi (Quality Assurance), geliştirme sürecinin sonuna bırakılan bir aşama değil, her satır kodun ayrılmaz bir parçasıdır.

```
                  ┌──────────────┐
                  │  E2E Tests   │  (%5)  Playwright / Cypress
                  │  (Tarayıcı)  │
               ┌──┴──────────────┴──┐
               │   Contract Tests   │  (%15) Pact (API Sözleşmeleri)
               │   (Entegrasyon)    │
            ┌──┴────────────────────┴──┐
            │    Integration Tests     │  (%30) Testcontainers
            │ (Postgres, Kafka, Redis) │
         ┌──┴──────────────────────────┴──┐
         │          Unit Tests            │  (%50) JUnit 5, Mockito
         │  (Domain Aggregates & VOs)     │
         └────────────────────────────────┘
```

---

## 8.2 Test Katmanlarının Detaylı İşleyişi

### 1. Birim Testler (Unit Tests - JUnit 5 & Mockito):
- **Odak Alanı:** Domain katmanı, Değer Nesneleri (`TenantId`, `Money`, `SubscriptionPlan`) ve Aggregate Root'lar (`SubscriptionAggregate`).
- **Prensip:** Sıfır dış bağımlılık; veritabanı veya ağ çağrısı yapılmaz. Mikro saniyeler seviyesinde çalışır.
- **TDD Yaklaşımı:** Junior mühendisler önce başarısız testi (Red), ardından çalışan en sade kodu (Green), son olarak mimari iyileştirmeyi (Refactor) yazar.

### 2. Entegrasyon Testleri (Integration Tests - Testcontainers):
- **Odak Alanı:** Repository adaptörleri, Kafka yayıncıları ve Redis önbellek işlemleri.
- **Testcontainers Kullanımı:** Mock veritabanı (H2 vb.) kullanılmaz; çünkü H2, PostgreSQL'in Row-Level Security (RLS) ve JSONB fonksiyonlarını desteklemez. Docker üzerinde saniyeler içinde geçici gerçek PostgreSQL 16 ve Kafka konteynerleri ayağa kaldırılarak gerçek SQL sorguları test edilir.

### 3. Sözleşme Testleri (Consumer-Driven Contract Testing - Pact):
- **Problem:** Frontend (Next.js) veya diğer mikroservisler arka yüz API'sinde bir alanın adı değiştiğinde runtime'da patlayabilir.
- **Çözüm:** Tüketici servis (Consumer), beklediği JSON sözleşmesini Pact dosyası olarak tanımlar. Backend CI hattında bu sözleşmeye uyum doğrulanmadan kod birleştirilemez.

### 4. Uçtan Uca Testler (E2E Tests - Playwright):
- **Senaryo:** Yeni bir kiracının kayıt olması, Starter planını seçmesi, kredi kartıyla ödeme yapması ve ardından ilk iş akışını tetiklemesi tarayıcı seviyesinde simüle edilir.

### 5. Yük ve Stres Testleri (k6 / Locust):
- Her sprint öncesi k6 senaryolarıyla saniyede 5,000 istek yük bindirilerek p99 yanıt süresinin 150 ms altında kalıp kalmadığı doğrulanır.

---

## 8.3 Bilgi Güvenliği (SecOps) ve Kurumsal Standartlar

### 1. OWASP Top 10 Savunma Mekanizmaları:
- **Injection Önleme:** PostgreSQL sorgularında Hibernate JPA Parametreli Sorguları ve PreparedStatement zorunludur; asla String birleştirme ile SQL yazılmaz.
- **Bozuk Yetkilendirme (Broken Access Control):** Spring Security `@PreAuthorize` anotasyonları ve PostgreSQL Row-Level Security (RLS) ile çift katmanlı kiracı denetimi uygulanır.
- **Güvenlik Açıklı Bağımlılıklar:** GitHub Actions hattında Trivy ve OWASP Dependency Check her PR'da otomatik çalışır; CVE skoru yüksek bağımlılık varsa derleme kırılır.

### 2. Kiracı Veri İzolasyonunun Doğrulanması (Penetration Test):
QA ve Güvenlik ekipleri her sprintte özel sızma testleri koşar:
- *"A Kiracısının JWT token'ı ile B Kiracısının iş akışı ID'sine istek atıldığında sistem 403 Forbidden dönüyor mu?"*
- *"PostgreSQL SQL enjeksiyonu denemesiyle RLS politikası delinebiliyor mu?"*

### 3. Sıfır Sabit Şifre İlkesi (Zero-Hardcoded Secrets):
- Git reposunda tek bir şifre, gizli anahtar veya API anahtarı barındırılması kesinlikle yasaktır (Git-secrets ve TruffleHog ile engellenir).
- Tüm sırlar Google Cloud Secret Manager'dan runtime'da dinamik okunur.
