# Bölüm 4: Alan Odaklı Tasarım (DDD) Taktiksel Tasarım ve Mimari İlkeler

## 4.1 Altıgen Mimari (Hexagonal / Ports & Adapters Architecture)
NexusCloud platformunda tüm servisler **Altıgen Mimari (Hexagonal Architecture)** prensiplerine göre katmanlandırılmıştır. Temel felsefe: **İş mantığı (Domain), veritabanından, web protokollerinden, mesaj kuyruklarından ve üçüncü taraf kütüphanelerden tamamen bağımsız olmalıdır.**

```
┌────────────────────────────────────────────────────────────────────────┐
│                        DIŞ DÜNYA (ADAPTERS)                            │
│                                                                        │
│   [ Next.js UI ] ──► (REST Controller) ─┐                             │
│                                          │                             │
│   [ Kafka Consumer ] ───────────────────┼──► [ SÜRÜCÜ PORTLAR ]        │
│                                          │   (Primary / Driving Ports) │
│                                          ▼                             │
│   ┌──────────────────────────────────────────────────────────────┐     │
│   │                 UYGULAMA KATMANI (APPLICATION)               │     │
│   │       Use Cases • Command Handlers • Query Handlers          │     │
│   │                              │                               │     │
│   │                              ▼                               │     │
│   │                 ÇEKİRDEK DOMAIN KATMANI                      │     │
│   │    Aggregate Roots • Entities • Value Objects • Events       │     │
│   │                              │                               │     │
│   │                              ▼                               │     │
│   │                     [ SÜRÜLEN PORTLAR ]                      │     │
│   │                  (Secondary / Driven Ports)                  │     │
│   └──────────────────────────────┬───────────────────────────────┘     │
│                                  │                                     │
│         ┌────────────────────────┼────────────────────────┐            │
│         ▼                        ▼                        ▼            │
│  (PostgreSQL Repo)        (Redis Cache)            (Kafka Producer)    │
│  PostgreSQL 16 RLS       Redis L2 Cache           Event Sourcing Bus   │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 4.2 Değer Nesneleri (Value Objects)
Değer Nesneleri, DDD'nin en temel yapı taşlarıdır. Özellikleri:
1. **Kimliksizlik (Identity-less):** Bir kimlikleri (ID) yoktur; sadece taşıdıkları değerlerle tanımlanırlar. İki nesnenin tüm nitelikleri aynıysa bu iki nesne birbirine eşittir.
2. **Değişmezlik (Immutability):** Bir kez oluşturulduktan sonra iç durumları asla değiştirilemez (Java `record` veya `final class`).
3. **Kendi Kendini Doğrulama (Self-Validation):** Asla geçersiz bir durumda oluşturulamazlar (Fail-fast prensibi).

### SaaS Örneği: `TenantId` ve `Money`
- `TenantId`: Boş veya tanımsız olamaz; UUID veya geçerli bir DNS slug formatında olmak zorundadır.
- `Money`: Negatif olamaz; ISO-4217 para birimi koduyla eşleşmelidir; farklı para birimleri doğrudan toplanamaz (önce döviz kuru dönüşümü gerekir).

---

## 4.3 Varlıklar ve Kök Nesneler (Entities & Aggregate Roots)
Bir Aggregate, işlem tutarlılığı sınırını (Transactional Consistency Boundary) belirleyen bir veya birden fazla Entity ve Value Object kümesidir.

### Temel Kurallar:
- Dış dünya doğrudan aggregate'in içindeki parçalara (örneğin bir alt satıra veya tekil bir adıma) erişemez.
- Tüm erişim ve iş kuralları **Kök Nesne (Aggregate Root)** üzerinden yürütülür.
- Veritabanı işlemleri aggregate bütünlüğü temelinde commit edilir.

### `SubscriptionAggregate` İş Kuralları (Invariants):
1. **İptal Durumu:** İptal edilmiş (`CANCELLED`) bir abonelik üzerinde plan değişikliği yapılamaz, yenilenemez ve askıya alınamaz.
2. **Tekillik:** Bir kiracının aynı anda yalnızca bir adet aktif veya deneme (`ACTIVE` / `TRIAL`) aboneliği bulunabilir.
3. **Süreklilik:** Bir abonelik aktifleştiğinde veya yenilendiğinde bitiş tarihi (`periodEnd`) mutlaka başlangıç tarihinden (`periodStart`) ileri bir tarih olmalıdır.

---

## 4.4 Domain Events (Alan Olayları)
Bir aggregate'in iç durumu iş kuralı gereği değiştiğinde (örneğin `Subscription.initiate()` veya `Subscription.changePlan()`), sistem bu durumu bildirmek üzere bir **Domain Event** üretir.

- Olaylar geçmiş zamanda adlandırılır: `SubscriptionCreatedEvent`, `PlanUpgradedEvent`, `SubscriptionSuspendedEvent`.
- Olay nesneleri değişmezdir (immutable) ve olayın gerçekleştiği anı (`Instant occurredAt`), aggregate kimliğini ve kiracı kimliğini taşır.

---

## 4.5 Depo Portları ve Adaptörleri (Repository Pattern)
DDD'de domain katmanı asla SQL, Hibernate veya JPA bilmez.
- **Domain Katmanı:** Sadece `ISubscriptionRepository` arayüzünü (Port) tanımlar.
- **Altyapı Katmanı (Infrastructure):** Bu arayüzü `PostgresSubscriptionRepositoryAdapter` sınıfı ile implemente eder. Burada Spring Data JPA veya JDBC kullanılarak PostgreSQL tablolarına yazılır.

---

## 4.6 Uygulama Servisleri ve CQRS Ayrımı
Uygulama Katmanı (Application Service), dış dünyadan gelen komutları alır, güvenlik ve yetki kontrollerini doğrular, repository'den aggregate'i yükler, aggregate üzerindeki iş metodunu çağırır ve sonucu kalıcı hale getirir.

- **Komut (Command):** Durumu değiştiren operasyonlar (Örn: `CreateSubscriptionCommand`). Yanıt olarak sadece ID veya başarı durumu döner.
- **Sorgu (Query):** Durumu değiştirmeyen, salt veri okuyan operasyonlar. Performans için doğrudan Redis veya PostgreSQL okuma projeksiyonlarından çekilir.

---

## 4.7 Çift Yazma (Dual-Write) Problemi ve Transactional Outbox Pattern
Bir SaaS mimarisinde en büyük felaket, veritabanına yazılıp Kafka'ya mesaj gönderilirken ağın kopmasıdır. Bu durumda veritabanında abonelik oluşur ancak faturalama ve bildirim servisleri bunu öğrenemez (Veri tutarsızlığı).

```
[ HTTP İsteği ]
       │
       ▼
┌────────────────────────────────────────────────────────┐
│             POSTGRESQL TEKİL TRANSACTION                │
│                                                        │
│  1. INSERT INTO subscriptions (id, tenant_id, ...)    │
│  2. INSERT INTO subscription_outbox_events (payload)   │
│                                                        │
│  COMMIT (Her ikisi aynı anda kaydedilir)               │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│         DEBEZIUM CDC / KAFKA CONNECT YA DA             │
│            ARKA PLAN OUTBOX YAYINCISI                  │
│                                                        │
│  • Outbox tablosundaki PENDING kayıtları okur          │
│  • Apache Kafka'ya TenantId partition anahtarıyla yazar│
│  • Başarılı olunca durumu PUBLISHED yapar             │
└────────────────────────────────────────────────────────┘
```

NexusCloud'da **Transactional Outbox Pattern** kullanılarak:
1. `subscriptions` tablosu güncellenirken aynı veritabanı transaction'ı içinde `subscription_outbox_events` tablosuna domain event JSON formatında yazılır.
2. Bir arka plan işlemi (Debezium Change Data Capture veya Outbox Poller), bu kayıtları güvenle okuyup Apache Kafka'ya yayınlar.
3. Böylece %100 "At-least-once" (En az bir kez iletim) garantisi sağlanır; hiçbir iş akışı veya fatura olayı kaybolmaz.
