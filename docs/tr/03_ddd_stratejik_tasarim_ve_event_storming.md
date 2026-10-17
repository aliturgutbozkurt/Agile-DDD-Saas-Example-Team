# Bölüm 3: Alan Odaklı Tasarım (DDD) Stratejik Tasarım ve Event Storming

## 3.1 Problem Alanı ve Çözüm Alanı Ayrımı
Yazılım evimizin Baş Mimarı ve Ürün Yöneticileri, NexusCloud projesine başlarken ilk olarak **Problem Alanı (Problem Space)** ile **Çözüm Alanı (Solution Space)** sınırlarını netleştirmiştir.

```
┌────────────────────────────────────────────────────────────────────────┐
│                   PROBLEM ALANI (PROBLEM SPACE)                        │
│                                                                        │
│  ┌──────────────────────┐  ┌────────────────────┐  ┌────────────────┐  │
│  │     CORE DOMAIN      │  │ SUPPORTING DOMAIN  │  │ GENERIC DOMAIN │  │
│  │ Dağıtık Akıllı       │  │ Çoklu Kiracı       │  │ Kimlik (Auth)  │  │
│  │ İş Akışı Motoru      │  │ Abonelik ve Fatura │  │ Bildirim (SMS) │  │
│  └──────────────────────┘  └────────────────────┘  └────────────────┘  │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Çözüm Alanına Dönüşüm
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                    ÇÖZÜM ALANI (SOLUTION SPACE)                        │
│                                                                        │
│  ┌──────────────────────┐  ┌────────────────────┐  ┌────────────────┐  │
│  │  WORKFLOW CONTEXT    │  │  BILLING CONTEXT   │  │ IDENTITY CTX   │  │
│  │ (Java + Kafka + ES)  │  │ (Java + Postgres)  │  │ (Spring Sec)   │  │
│  └──────────────────────┘  └────────────────────┘  └────────────────┘  │
└────────────────────────────────────────────────────────────────────────┘
```

### 1. Çekirdek Alan (Core Domain): İş Akışı Orkestrasyon Motoru
- **Tanım:** NexusCloud'u rakiplerinden ayıran, şirketin en yüksek rekabet avantajını sağlayan alandır.
- **Yatırım Kararı:** Tüm kurumsal inovasyon, en kıdemli mühendisler ve özel algoritmalar bu alana yoğunlaştırılır. Asla hazır bir üçüncü taraf ürünle ikame edilmez.

### 2. Destekleyici Alt Alanlar (Supporting Subdomains): Abonelik & Çoklu Kiracılık
- **Tanım:** Çekirdek alanın çalışması ve ticari değere dönüşmesi için gerekli olan, işletmeye özgü iş kurallarını barındıran ancak başlı başına bir inovasyon olmayan alanlardır.
- **Yatırım Kararı:** Şirket içi geliştirilir; ancak basit tutulur ve çekirdek alanın önüne geçmesine izin verilmez.

### 3. Genel Alt Alanlar (Generic Subdomains): Kimlik, Bildirim ve Denetim Logları
- **Tanım:** Sektördeki her yazılımda bulunan, standartlaşmış problemlerdir (OAuth2, E-posta gönderimi, SMS).
- **Yatırım Kararı:** Mümkün olduğunca hazır kütüphaneler (Spring Security, SendGrid, Firebase vb.) veya standart protokoller kullanılır.

---

## 3.2 Event Storming Çalıştayı ve Olay Haritası
Sprint 0 öncesinde tüm ekipler (CTO, Mimarlar, PO'lar, Kıdemli ve Junior Mühendisler, QA ve Destek) 3 günlük kapsamlı bir **Event Storming** çalıştayı gerçekleştirmiştir.

### Renk Kodları ve Kavramlar:
- **Turuncu (Domain Event):** Geçmiş zamanda gerçekleşmiş kritik iş olayı (örn: `SubscriptionCreated`, `WorkflowExecuted`).
- **Mavi (Command):** Bir kullanıcı veya sistem tarafından tetiklenen eylem (örn: `CreateSubscription`, `TriggerWorkflow`).
- **Sarı (Aggregate):** İş kurallarını ve değişmezleri koruyan varlık kümesi (örn: `Subscription`, `WorkflowExecution`).
- **Yeşil (Read Model / View):** Kullanıcının karar verirken gördüğü veri projeksiyonu (örn: `TenantBillingSummaryView`).
- **Pembe (External System):** Sistem dışındaki servisler (örn: `Stripe Payment Gateway`, `SendGrid Mail API`).
- **Kırmızı (Hotspot / Problem):** Riskler, belirsizlikler veya açık sorular (örn: *"Bakiye yetersizse kaç gün sonra askıya alınacak?"*).

### Çalıştaydan Çıkan Olay Zaman Çizelgesi (Event Timeline):
1. `TenantRegistered` ➔ `TrialSubscriptionProvisioned` ➔ `DefaultWorkflowCreated`
2. `WorkflowTriggerReceived` ➔ `TenantQuotaChecked` ➔ `WorkflowExecutionStarted`
3. `StepExecutedSuccessfully` ➔ `WorkflowExecutionCompleted` ➔ `ExecutionMetered`
4. `BillingCycleEnded` ➔ `InvoiceGenerated` ➔ `PaymentChargedViaStripe` ➔ `SubscriptionRenewed`
5. *(Hotspot / Kriz Durumu)*: `PaymentFailed` ➔ `GracePeriodStarted` ➔ `DunningEmailSent` ➔ *(Ödeme yapılmazsa)* `SubscriptionSuspended`

---

## 3.3 Ortak Dil Sözlüğü (Ubiquitous Language Dictionary)
Yazılım evinde analistten destek ekibine, junior mühendisten CTO'ya herkesin kodda, toplantıda ve dokümanda aynı anlamda kullandığı ortak kavramlar:

| Terim (Türkçe) | Terim (İngilizce) | Bounded Context | Kesin Tanım ve İş Kuralı |
| :--- | :--- | :--- | :--- |
| **Kiracı** | **Tenant** | Identity & Core | Platformu kullanan kurumsal müşteri organizasyonu. Kendi kullanıcı ve verilerine sahiptir. |
| **Abonelik** | **Subscription** | Billing Context | Bir kiracının belirli bir zaman diliminde belirli haklara (kota, SLA) sahip olma sözleşmesi. |
| **Plan Seviyesi** | **Plan Tier** | Billing Context | Starter, Professional veya Enterprise katmanlarından biri. Fiyat ve sınırları belirler. |
| **İş Akışı** | **Workflow** | Workflow Context | Sıralı adımlardan (steps) ve tetikleyicilerden (triggers) oluşan yürütülebilir durum makinesi. |
| **Yürütme** | **Execution** | Workflow Context | Bir iş akışının belirli bir olay veya zamanlamayla somut olarak çalıştırılması örneği. |
| **Kullanım Ölçümü** | **Metered Usage** | Billing Context | Kiracının tükettiği yürütme adedi ve depolama miktarının faturalandırma için sayaçlanması. |
| **Askıya Alma** | **Suspension** | Billing Context | Fatura ödenmediğinde veya güvenlik ihlalinde kiracının iş akışlarının durdurulması. |
| **Olay Yolu** | **Outbox** | Shared Kernel | Veritabanı işlemiyle Kafka mesaj yayımını atomik yapan güvenilirlik tablosu. |

---

## 3.4 Sınırlandırılmış Bağlamlar (Bounded Contexts) ve Context Map
NexusCloud sistemi 4 ana Bounded Context'e ayrılmıştır.

```
┌─────────────────────────────────┐
│     IDENTITY & TENANT CONTEXT   │
│     (Upstream / Open Host)      │
└────────────────┬────────────────┘
                 │ Published Language (TenantCreated, TenantSuspended)
                 ▼
┌─────────────────────────────────┐           Anti-Corruption Layer (ACL)
│    SUBSCRIPTION & BILLING CTX   ├─────────────────────────────────────────┐
│       (Customer / Supplier)     │                                         │
└────────────────┬────────────────┘                                         │
                 │                                                          ▼
                 │ Domain Events (PlanUpgraded, QuotaExceeded)    ┌──────────────────┐
                 ▼                                                │ WORKFLOW ENGINE  │
┌─────────────────────────────────┐                               │   CORE CONTEXT   │
│      NOTIFICATION CONTEXT       │◄──────────────────────────────┤  (Core Domain)   │
│       (Generic Subdomain)       │  Events (StepFailed, Alert)   └──────────────────┘
└─────────────────────────────────┘
```

### Bağlamlar Arası İlişki Tipleri (Context Mapping):
1. **Upstream / Downstream (Müşteri - Tedarikçi):**
   - Identity Context üst akıştır (Upstream). Subscription Context alt akıştır (Downstream). Kiracı oluşturulmadan abonelik var olamaz.
2. **Anti-Corruption Layer (ACL - Yolsuzluk Önleme Katmanı):**
   - Workflow Context, Billing Context'ten gelen ham veri modellerini doğrudan kendi domain modeline almaz. Bir ACL adaptörü vasıtasıyla `BillingEvent` nesnesini kendi `QuotaPolicy` modeline tercüme eder.
3. **Open Host Service (OHS) / Published Language (PL):**
   - Identity Context, tüm diğer servislere standart JSON şemalarıyla yayınlanmış olaylar (Published Language) sunar.
4. **Separate Ways (Ayrı Yollar):**
   - Destek ve Log Analitiği için kullanılan Elasticsearch yapısı, ana transactional veritabanından tamamen bağımsız bir okuma modeli (Read Model) olarak konumlandırılmıştır.
