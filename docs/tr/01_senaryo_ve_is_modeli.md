# Bölüm 1: SaaS Senaryosu, Şirket Vizyonu ve B2B İş Modeli

## 1.1 Nexus Digital Systems Yazılım Evi Hikayesi
**Nexus Digital Systems**, yüksek işlem hacmine sahip B2B girişimlere ve kurumsal şirketlere uçtan uca dijital ürünler geliştiren uluslararası standartlarda bir yazılım evidir (Software House & Product Studio). Şirket, pazardaki yüzlerce müşterinin benzer sorunlarla boğuştuğunu gözlemlemiştir:
1. Şirket içi iş akışları (veri onayları, fatura mutabakatları, üçüncü taraf entegrasyonlar) parçalı ve kırılgandır.
2. Farklı sistemler arasındaki olaylar (events) kaybolmakta ya da çift işlenmektedir.
3. Çoklu kiracılık (Multi-Tenancy) altyapısı kurmak yüksek ilk yatırım maliyeti gerektirmektedir.

Bu vizyonla Nexus Digital Systems yönetimi, şirketin amiral gemisi ürünü olacak **NexusCloud SaaS** platformunu geliştirme kararı almıştır. Bu proje, hem şirketin kendi SaaS ürünü olarak küresel pazara sunulacak hem de yazılım evinin tüm mühendislik kadrosu için en yüksek standartları tanımlayan referans mimari olacaktır.

---

## 1.2 NexusCloud SaaS Ürün Tanımı ve Değer Önerisi
**NexusCloud**, kurumsal işletmelerin veri akışlarını, üçüncü taraf API çağrılarını ve zamanlanmış görevlerini olay güdümlü (event-driven) kurallarla birbirine bağlayan, kullanım bazlı faturalandırma sağlayan yeni nesil bir **Akıllı İş Akışı ve Olay Orkestrasyon Platformudur**.

### Temel Ürün Kabiliyetleri:
- **Çoklu Kiracılık (Multi-Tenancy):** Tek bir merkezi bulut altyapısı üzerinde binlerce bağımsız kurumsal kiracının (tenant) tam veri, önbellek ve mesaj izolasyonuyla güvenli çalışması.
- **Dağıtık İş Akışı Motoru (Distributed Workflow Engine):** REST API, Webhook veya zamanlanmış (Cron) tetikleyicilerle başlayan, koşullu dallanmalara sahip, hata durumunda kendini onarabilen durum makineleri (State Machines).
- **Abonelik ve Gelir Yönetimi (Subscription & Monetization):** Starter, Professional ve Enterprise katmanlarında dinamik faturalandırma, kredi/kullanım kotası takibi ve otomatik tahsilat süreçleri.
- **Yüksek Hacimli Olay Akışı (Event Streaming):** Apache Kafka omurgası üzerinde saniyede yüzbinlerce olayın mikro saniyeler seviyesinde güvenle sıralı işlenmesi.
- **Kurumsal Arama ve Güvenlik Denetimi:** Elasticsearch üzerinde kiracı bazlı saniyeler altı log, audit trail ve iş akışı geçmişi arama imkânı.

---

## 1.3 İş Modeli, Gelir Katmanları ve SLA Taahhütleri
NexusCloud, kurumsal B2B abonelik modeline (Subscription-as-a-Service) dayalıdır. Gelir modeli aylık sabit abonelik ücreti ile kota aşımında devreye giren kullanım bazlı (pay-as-you-go) modelin hibrit bir birleşimidir.

### Abonelik Paketleri ve Hizmet Seviyesi Sözleşmesi (SLA) Matrisi

| Parametre | Starter Plan | Professional Plan | Enterprise Plan |
| :--- | :--- | :--- | :--- |
| **Aylık Taban Ücret** | $49 / ay | $199 / ay | $799+ / ay (Özel Fiyatlama) |
| **Maksimum İş Akışı Sayısı** | 10 Adet | 50 Adet | Sınırsız |
| **Aylık Yürütme (Execution) Kotası**| 10,000 işlem | 100,000 işlem | 2,000,000+ işlem |
| **Kota Aşım Ücreti** | Her 1,000 işlem için $2 | Her 1,000 işlem için $1 | Özel hacim indirimi |
| **Sözleşmeli SLA Garantisi** | **%99.50 Uptime** | **%99.90 Uptime** | **%99.95 Uptime** |
| **İzin Verilen Aylık Kesinti** | Maks. 3 saat 39 dakika | Maks. 43 dakika 48 saniye | **Maks. 21 dakika 54 saniye** |
| **Destek Seviyesi** | Standart E-posta (24 saat) | Öncelikli Chat & E-posta (4 saat)| 7/24 Telefon & Özel Slack / TAM (< 15 dk) |
| **Veri İzolasyon Modeli** | PostgreSQL RLS (Mantıksal) | PostgreSQL RLS + Ayrılmış Havuz | **Ayrılmış PostgreSQL Şeması / Hibrit** |

---

## 1.4 Çoklu Kiracılık (Multi-Tenancy) Stratejisi
Yazılım evinin CTO ve Baş Mimarı, veri güvenliği ile altyapı maliyetini optimize etmek adına **Hibrit Çoklu Kiracılık Mimarisi** benimsemiştir:

1. **İlişkisel Veri İzolasyonu (PostgreSQL):**
   - **Starter ve Professional Kiracılar:** Paylaşımlı veritabanı ve paylaşımlı tablolar kullanılır. Her tabloda zorunlu `tenant_id` kolonu bulunur ve PostgreSQL **Row-Level Security (RLS)** mekanizmasıyla veri tabanı motoru seviyesinde çapraz kiracı erişimi engellenir.
   - **Enterprise Kiracılar:** Veri tabanı içinde `tenant_{id}` adında bağımsız bir PostgreSQL şeması (schema) otomatik olarak Flyway ile provizyonlanır.
2. **Dağıtık Önbellek İzolasyonu (Redis):**
   - Önbellek anahtarları katı bir ad alanı (namespace) hiyerarşisiyle tutulur: `nexus:tenant:{tenant_id}:{aggregate}:{id}`.
   - Kiracı bazlı hız sınırlama (Rate Limiting) token bucket algoritmasıyla Redis üzerinde yürütülür.
3. **Mesajlaşma ve Kuyruk İzolasyonu (Apache Kafka):**
   - Tüm iş akışı ve faturalama olaylarında `tenant_id` Kafka mesaj anahtarı (Message Key) olarak kullanılır. Bu sayede aynı kiracıya ait olaylar daima aynı partition'a yönlendirilir ve sıralılık (in-order processing) korunur.
4. **Arama ve İndeksleme İzolasyonu (Elasticsearch):**
   - Belgeler `tenantId` keyword alanı ile indekslenir ve Elasticsearch Alias / Filtered Index yapılandırmasıyla sorgu seviyesinde kiracı dışına çıkılması imkansız kılınır.

---

## 1.5 Finansal ve Operasyonel Başarı Metrikleri (KPIs)
Yazılım evinin yönetim kurulu ve ürün liderleri şu metrikleri günlük olarak izler:
- **MRR (Monthly Recurring Revenue):** Aylık tekrarlayan gelir hedefi.
- **ARR (Annual Recurring Revenue):** Yıllık tekrarlayan gelir projeksiyonu.
- **Net Churn Rate:** Aylık müşteri kaybı oranının %1.5'in altında tutulması.
- **CAC Payback Period:** Müşteri kazanım maliyetinin 8 aydan kısa sürede amorti edilmesi.
- **Altyapı Birim Maliyeti (Infrastructure COGS per Tenant):** Her bir kiracının bulut kaynak tüketim maliyetinin elde edilen gelirin %12'sini aşmaması.
