# Bölüm 9: Teknik Destek (L1/L2), Olay (Incident) ve Kriz Yönetimi

## 9.1 Destek Kademeleri ve Eskalasyon Matrisi
Canlı ortamda bir aksaklık meydana geldiğinde, mühendislik ekibinin odağını korumak ve müşteriye taahhüt edilen SLA sürelerine uyabilmek için 3 kademeli eskalasyon protokolü işletilir:

```
[ Müşteri Bildirimi / Alert ]
             │
             ▼
┌──────────────────────────────────────────────┐
│  L1 MÜŞTERİ DESTEK (Helpdesk)                │
│  • Yanıt Süresi Hedefi: < 15 dakika          │
│  • Görev: Bilet sınıflandırma, ilk yanıt     │
│    ve standart runbook işletimi              │
└──────────────────────┬───────────────────────┘
                       │ (Teknik derinlik gerekiyorsa)
                       ▼
┌──────────────────────────────────────────────┐
│  L2 TEKNİK DESTEK (Technical Support Eng.)   │
│  • Yanıt Süresi Hedefi: < 30 dakika          │
│  • Görev: Elasticsearch log incelemesi,      │
│    OpenTelemetry iz sürme, tenant doğrulama  │
└──────────────────────┬───────────────────────┘
                       │ (Yazılım hatası / Altyapı çöküşü)
                       ▼
┌──────────────────────────────────────────────┐
│  L3 MÜHENDİSLİK & NÖBETÇİ EKİP (On-Call SRE) │
│  • Yanıt Süresi Hedefi: < 15 dakika (Sev-1)  │
│  • Görev: Kod içi hata ayıklama, hotfix      │
│    dağıtımı ve altyapı müdahalesi            │
└──────────────────────────────────────────────┘
```

---

## 9.2 Canlı Olay Senaryosu: Sev-1 Kritik Kesinti Simülasyonu

### Olay Başlığı:
**INC-4819: Kafka Tüketici Çökmesi ve Ödeme Webhook'larında Kuyruk Birikmesi**

### Olay Kronolojisi:
- **14:15:** Ödeme geçidi Stripe, Black Friday yoğunluğu nedeniyle webhook çağrılarını toplu (burst) olarak saniyede 12,000 istek seviyesine çıkarır.
- **14:18:** PagerDuty Alarmı tetiklenir: `KafkaConsumerLagHigh (Topic: nexus.billing.subscription-events.v1 > 15,000 msgs)`.
- **14:20 (L1 Destek):** Enterprise bir müşteriden bildirim gelir: *"Planımızı Enterprise'a yükselttik ancak iş akışı kotamız hala güncellenmedi."* L1 Destek bileti Sev-1 olarak etiketler ve L2'ye aktarır.
- **14:23 (L2 Destek):** L2 mühendisi Elasticsearch ve Kibana'ya girerek tenant loglarını inceler. Tüketici pod'larının `OutOfMemoryError: Java heap space` hatasıyla yeniden başladığını (CrashLoopBackOff) görür. Derhal L3 On-Call Nöbetçi Mühendisi ve SRE'yi uyandırır.
- **14:25 (L3 & SRE):** **Incident Commander (Olay Yöneticisi)** atanır. Discord/Slack üzerinde sesli **War Room** açılır. Şirketin genel durum sayfası (`status.nexuscloud.io`) güncellenir: *"Abonelik güncellemelerinde gecikmeler yaşanmaktadır. İncelememiz sürmektedir."*

---

## 9.3 Olay Müdahalesi ve Çözüm (Mitigation)
1. **Teşhis:** Gelen büyük JSON payload'ları Jackson tarafından deserialize edilirken JVM heap limiti (1024Mi) yetersiz kalmış ve G1GC aşırı CPU tüketmiştir.
2. **Geçici Çözüm (Mitigation):**
   - SRE ekibi kubectl üzerinden tüketici pod'larının bellek sınırını geçici olarak 2048Mi'ye çeker ve HPA replica sayısını 3'ten 10'a çıkarır:
     `kubectl scale deployment/nexus-subscription-service --replicas=10 -n production`.
   - Redis önbellek bağlantı havuzu genişletilir.
3. **14:42:** Kafka tüketici lag'i 0'a iner. Tüm geciken webhook'lar işlenir, kiracıların kotaları güncellenir.
4. **14:48:** Sistem tamamen normale döner. Durum sayfası "Tüm sistemler çalışıyor" olarak kapatılır. Toplam kesinti süresi: **28 dakika**.

---

## 9.4 Kök Neden Analizi (Root Cause Analysis - 5 Neden / 5 Whys Metodu)
Mühendislik ekibi olay sonrasında toplanarak 5 Neden analizini yürütür:

1. **Neden kotalar güncellenmedi?**  
   ➔ Çünkü Kafka'daki `SubscriptionCreatedEvent` mesajları zamanında tüketilemedi; kuyrukta bekledi.
2. **Neden mesajlar tüketilemedi?**  
   ➔ Çünkü abonelik servisi Pod'ları OOM (Out of Memory) hatası alarak sürekli çöktü.
3. **Neden pod'lar OOM aldı?**  
   ➔ Çünkü Stripe'tan gelen anlık 12,000 istek toplu olarak işlenirken bellek tüketimi 1 GB limitini aştı.
4. **Neden bellek sınırı yetersiz kaldı ve pod'lar yatayda ölçeklenemedi?**  
   ➔ Çünkü HPA yalnızca CPU metriğine bağlıydı; Kafka tüketici gecikmesini (Lag) izleyen bir KEDA metrik ölçekleyicisi yapılandırılmamıştı.
5. **Neden KEDA ölçekleyicisi kurulmamıştı?**  
   ➔ Çünkü altyapı tasarımında Kafka lag bazlı otomatik ölçekleme gereksinimi backlog'da düşük önceliklendirilmişti.

---

## 9.5 Suçlamasız Olay Raporu (Blameless Post-Mortem) ve Önleyici Aksiyonlar
Nexus Digital Systems kültüründe bireyler suçlanmaz; sistemin zayıflıkları onarılır.

### Çıkarılan Önleyici Aksiyon Maddeleri (Action Items):
| Aksiyon Maddesi | Sorumlu | Öncelik | Hedef Tarih |
| :--- | :--- | :--- | :--- |
| GKE kümesine KEDA kurularak Kafka Lag metriğine göre otomatik Pod ölçekleme yapılması | SRE / DevOps | P0 (Kritik) | 3 Gün |
| JVM bellek parametrelerinin `-XX:MaxRAMPercentage=75.0` olarak optimize edilmesi | Lead Backend Dev | P1 (Yüksek) | 2 Gün |
| Stripe Webhook isteklerine Spring Cloud Gateway üzerinde Token Bucket hız sınırlaması konulması | Senior Backend Dev | P1 (Yüksek) | 1 Hafta |
| L1/L2 Destek Ekibi için "Kafka Lag Tıkanıklığı Müdahale Runbook'u" hazırlanması | L2 Support Lead | P2 (Orta) | 1 Hafta |
