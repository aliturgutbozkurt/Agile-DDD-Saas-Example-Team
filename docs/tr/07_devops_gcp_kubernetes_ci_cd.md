# Bölüm 7: DevOps, GCP, Kubernetes ve CI/CD Pipeline Mimarisi

## 7.1 Google Cloud Platform (GCP) Altyapı Mimarisi
NexusCloud, kurumsal SLA gereksinimlerini karşılamak üzere Google Cloud Platform üzerinde yüksek erişilebilirlikli (High Availability - HA) ve çok bölgeli (Multi-Zone) olarak kurgulanmıştır.

```
┌────────────────────────────────────────────────────────────────────────┐
│                        GOOGLE CLOUD REGION (us-central1)               │
│                                                                        │
│   Zone us-central1-a         Zone us-central1-b      Zone us-central1-c│
│  ┌────────────────────┐    ┌────────────────────┐   ┌────────────────┐ │
│  │ GKE Node Pool 1    │    │ GKE Node Pool 2    │   │ GKE Node Pool 3│ │
│  │ (e2-standard-4)    │    │ (e2-standard-4)    │   │ (e2-standard-4)│ │
│  └─────────┬──────────┘    └─────────┬──────────┘   └────────┬───────┘ │
│            │                         │                       │         │
│            └─────────────────────────┼───────────────────────┘         │
│                                      │                                 │
│                                      ▼                                 │
│            ┌───────────────────────────────────────────────┐           │
│            │       YÖNETİLEN VERİ SERVİSLERİ (GCP HA)       │           │
│            │  • Cloud SQL PostgreSQL 16 (HA Failover Node) │           │
│            │  • Memorystore for Redis (Replicated Cluster) │           │
│            │  • GCP Secret Manager & KMS Entegrasyonu      │           │
│            └───────────────────────────────────────────────┘           │
└────────────────────────────────────────────────────────────────────────┘
```

### Kod Olarak Altyapı (Infrastructure as Code - Terraform):
Tüm bulut kaynakları (VPC ağları, alt ağlar, güvenlik duvarı kuralları, GKE kümeleri, Cloud SQL örnekleri) Terraform modülleri ile sürüm kontrolünde yönetilir. Elle (manual) yapılan hiçbir bulut değişikliğine izin verilmez.

---

## 7.2 Google Kubernetes Engine (GKE) Yapılandırması
- **Workload Identity Federation:** Kubernetes Pod'larının GCP IAM rollerine erişmesi için sabit JSON servis hesabı anahtarı (Service Account Key) kullanılmaz. GKE Workload Identity ile Pod ServiceAccount doğrudan IAM rolüne bağlanır; böylece kimlik hırsızlığı riski sıfırlanır.
- **Horizontal Pod Autoscaler (HPA):**
  - CPU kullanımı > %70 veya bellek > %80 olduğunda Pod sayısı otomatik olarak 3'ten 15'e kadar yükseltilir.
  - Yoğun kampanya dönemlerinde gecikme yaşamadan yatay ölçeklenme sağlanır.
- **Sıfır Kesintili Dağıtım (Zero-Downtime Rolling Update):**
  - `maxSurge: 1` ve `maxUnavailable: 0` yapılandırması sayesinde yeni sürüm Pod ayağa kalkıp Spring Boot Actuator `readinessProbe` başarılı yanıt vermeden eski Pod sonlandırılmaz.

---

## 7.3 GitHub Actions Çok Aşamalı CI/CD Boru Hattı

```
[ Push / PR Event ]
       │
       ▼
┌────────────────────────────────────────────────────────┐
│ 1. Statik Analiz & Güvenlik Kapısı (Lint & SonarQube) │
│    • Checkstyle • OWASP Dependency Check • Trivy FS    │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ 2. TDD & Test Otomasyonu (Testcontainers)              │
│    • JUnit 5 Unit Tests • PostgreSQL Entegrasyon Testi │
│    • Apache Kafka Mesaj Akış Testi (Gerçek Konteyner)  │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ 3. Konteyner Derleme & Paketleme                       │
│    • Multi-stage Docker Build (Alpine Temurin 21)      │
│    • Google Artifact Registry'ye İtme (GCP Auth WIF)   │
└──────────────────────────┬─────────────────────────────┘
                           │ (Yalnızca 'main' branch birleştiğinde)
                           ▼
┌────────────────────────────────────────────────────────┐
│ 4. Kubernetes Dağıtımı & Doğrulama (GKE Rollout)       │
│    • kubectl apply -f k8s/                             │
│    • kubectl rollout status --timeout=180s             │
│    • Otomatik Duman Testi (Smoke Test Verification)    │
└────────────────────────────────────────────────────────┘
```

---

## 7.4 Gözlemlenebilirlik (Observability Üçgeni)

### 1. Metrikler (Metrics - Prometheus & Grafana):
- Spring Boot Micrometer kütüphanesi tüm metrikleri `/actuator/prometheus` üzerinden dışa aktarır.
- **Kritik Panolar:**
  - HTTP İstek Sayısı ve Ortalama Yanıt Süresi (p50, p95, p99).
  - PostgreSQL HikariCP Bağlantı Havuzu Durumu (Active, Idle, Waiting Connections).
  - Redis Hit/Miss Oranı ve Eviction Sayısı.
  - Kafka Consumer Lag (Tüketici gecikmesi): 1000 mesajı geçerse nöbetçi mühendise PagerDuty alarmı iletilir.

### 2. Loglama (Logging - JSON & Elasticsearch / GCP Cloud Logging):
- Tüm mikroservisler standart yapılandırılmış (Structured JSON) formatında log üretir.
- Her log satırında şu alanlar zorunludur:
  `{"timestamp": "...", "level": "INFO", "tenantId": "acme", "traceId": "abc123xyz", "spanId": "...", "message": "..."}`.
- Kibana veya Google Cloud Operations arayüzünde tek bir `traceId` veya `tenantId` ile tüm servislerdeki hareketler anında süzülür.

### 3. Dağıtık İzleme (Distributed Tracing - OpenTelemetry & Jaeger):
- Bir kullanıcı Next.js arayüzünden butona bastığında üretilen W3C Trace Context başlığı (`traceparent`), API Gateway'den mikroservislere, oradan veritabanına ve Kafka mesajlarına kadar iletilir.
- Hangi adımın kaç milisaniye sürdüğü, gecikmenin veritabanı kilidinden mi yoksa harici API çağrısından mı kaynaklandığı Jaeger üzerinde su damlası grafiğiyle izlenir.

---

## 7.5 Hata Bütçesi (Error Budget) ve SLA / SLO / SLI Matematiksel Yönetimi
Kurumsal müşterilere taahhüt edilen **%99.95 Uptime SLA**, bir ayda (30 gün = 43,200 dakika) en fazla **21.6 dakika kesinti** veya hatalı istek hakkı tanır.

- **Hata Bütçesi (Error Budget):** Toplam izin verilen hata toleransıdır (%0.05).
- **Hata Bütçesi Politikasının İşletilmesi:**
  - Eğer takımların bir ay içindeki hata bütçesi tüketimi %80'e ulaşırsa, yeni özellik dağıtımları durdurulur.
  - Tüm ekipler yalnızca teknik borç kapatma, performans iyileştirme ve dayanıklılık (resilience) geliştirmelerine odaklanır.
