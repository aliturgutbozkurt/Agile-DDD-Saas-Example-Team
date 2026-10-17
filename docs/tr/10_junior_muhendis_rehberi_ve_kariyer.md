# Bölüm 10: Junior Mühendisin Saha Rehberi ve Kariyer Yolculuğu

## 10.1 Yazılım Evinde İlk 30-60-90 Gün Onboarding Yol Haritası
Nexus Digital Systems'a yeni katılan bir Junior Mühendisin başarıya ulaşması şansa bırakılmaz; yapılandırılmış bir rehberlikle desteklenir.

```
┌────────────────────────────────────────────────────────────────────────┐
│                        JUNIOR ONBOARDING ROTASI                        │
│                                                                        │
│   İLK 30 GÜN: UYUM & İLK KATKI                                         │
│   • Docker Compose ile yerel ortamı kurma                              │
│   • Domain dilini (Ubiquitous Language) öğrenme                        │
│   • İlk Value Object geliştirmesi ve ilk onaylanan PR                  │
│                                                                        │
│   31 - 60 GÜN: BAĞIMSIZLIK & ÇİFTLİ ÇALIŞMA (PAIRING)                  │
│   • Tam bir User Story'yi baştan sona tamamlama                        │
│   • Testcontainers ile ilk entegrasyon testini yazma                   │
│   • Senior mühendis ile haftalık 2 seans Pair Programming               │
│                                                                        │
│   61 - 90 GÜN: DERİNLEŞME & GÖLGE NÖBETÇİLİK (SHADOW ON-CALL)         │
│   • Kafka olay tüketicisi veya Redis önbellek geliştirmesi             │
│   • Canlı operasyonlarda L2/L3 nöbetçi mühendisi gölge olarak izleme   │
│   • Takım içi teknik sunum (Lunch & Learn) yapma                       │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 10.2 Bir Kullanıcı Hikayesini (User Story) Ele Alma ve Koda Dönüştürme Sanatı
Junior mühendis, Jira'dan bir iş kartı aldığında doğrudan koda atlamamalıdır:

1. **Adım 1: Kabul Kriterlerini Okuma:** Gherkin senaryolarını (`Given`, `When`, `Then`) anlamlandırır. Anlaşılmayan her detayı PO'ya refinement'ta veya doğrudan sorar.
2. **Adım 2: Domain Sınırlarını Çizme:** *"Bu iş bir Aggregate'in içine mi giriyor, yeni bir Value Object mi gerekiyor yoksa sadece bir adaptör mü?"* sorusunu yanıtlar.
3. **Adım 3: TDD ile Testi Yazma:** Kod yazmadan önce beklenen senaryoyu test eden JUnit metodunu yazar. Testin kırmızı yandığını görür.
4. **Adım 4: Kodu Yazma:** Testi yeşile çevirecek en sade kodu yazar.
5. **Adım 5: Refactoring & Temizlik:** Kodu DDD standartlarına göre düzenler, gereksiz yorum satırlarını temizler.

---

## 10.3 Git Branching ve Conventional Commits Standardı
- **Branch Adlandırma Kuralı:**  
  `feature/NEXUS-204-subscription-plan-upgrade` veya `fix/NEXUS-310-redis-ttl-leak`
- **Conventional Commits Formatı:**
  - `feat(billing): add SubscriptionPlan value object validation`
  - `test(subscription): add unit tests for invariant cancellation check`
  - `fix(kafka): resolve consumer deserialization error on null tenantId`
  - `docs(readme): update local docker-compose run instructions`

---

## 10.4 Kusursuz Bir Pull Request (PR) Hazırlama ve Code Review Kültürü

### Junior'ın PR Kontrol Listesi:
- [ ] PR boyutu küçük mü? (İdeal: < 250 satır değişiklik).
- [ ] PR başlığı ve açıklaması net mi? *"Ne yapıldı, neden yapıldı, nasıl test edildi?"*
- [ ] Yerel makinede `mvn clean test` ve linter hatasız çalıştı mı?
- [ ] Ekran görüntüsü veya log çıktısı PR açıklamasına eklendi mi?

### Senior Code Review Geri Bildirimlerine Yaklaşım:
- Senior mühendisin *"Bunu böyle yapmalısın"* yorumu kişisel bir eleştiri değil, teknik bir hediyedir.
- Anlaşılmayan yorumlara *"Neden bu yaklaşımı tercih etmeliyiz?"* diyerek öğrenme fırsatı olarak yaklaşılmalıdır.
- Yorumlar düzeltildikten sonra PR'da tek tek "Resolve conversation" işaretlenmeli ve senior bilgilendirilmelidir.

---

## 10.5 Pair Programming (Çiftli Programlama) Dinamikleri
- **Roller:** **Driver (Sürücü - Klavyedeki)** ve **Navigator (Navigatör - Düşünen/Yol Gösteren)**.
- Junior klavyede (Driver) olmalı, Senior ise mimari rehberlik (Navigator) yapmalıdır. Bu sayede kas hafızası Junior'da oluşur.
- **Soru Sorma Kuralı (15 Dakika Kuralı):** Bir problemle karşılaşıldığında önce 15 dakika boyunca loglar, dokümanlar ve kod geçmişi incelenir. Çözülemezse Senior'a şu şablonla soru sorulur:
  > *"Şu özelliği yapmaya çalışıyorum. X hatasını alıyorum. Y ve Z çözümlerini denedim fakat olmadı. Nerede yanlış düşünüyor olabilirim?"*

---

## 10.6 Kariyer Merdiveni: Junior'dan Mid ve Senior Seviyeye Yükselme
Nexus Digital Systems mühendislik merdiveninde bir üst seviyeye geçiş kriterleri:

| Yetkinlik Alanı | Junior Engineer | Mid-Level Engineer | Senior / Lead Engineer |
| :--- | :--- | :--- | :--- |
| **Özerklik (Autonomy)** | Detaylı yönerge ve rehberlikle çalışır. | Bağımsız hikaye teslim eder, az yönlendirme gerekir. | Ekibin teknik yönünü belirler, belirsizlikleri çözer. |
| **Mimari Hakimiyet** | Value Object ve basit servisleri yazar. | Hexagonal katmanları ve CQRS'i kusursuz uygular. | Bounded Context sınırlarını çizer, ADR yazar. |
| **Hata Çözme (Debugging)**| Stack trace okur, yerel ortamda debug eder. | OpenTelemetry ve Elasticsearch loglarını çözer. | Canlı kriz anında Incident Commander olur. |
| **Etki Alanı (Impact)** | Kendi görevlerini zamanında bitirir. | Takım içi kod kalitesini ve hızını artırır. | Şirket çapında mimari standartları belirler, mentörlük yapar. |
