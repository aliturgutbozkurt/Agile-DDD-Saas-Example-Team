# NexusCloud SaaS: End-to-End Enterprise Software Engineering Playbook
### From CTO to Junior Engineer with Domain-Driven Design (DDD) & Agile Scrum

> **Bilingual Project & Publications (İki Dilde Kurumsal Dokümantasyon ve PDF Kitaplar)**  
> Bu proje, kurumsal bir yazılım evinde (Software House) sıfırdan hayata geçirilen çok kiracılı (multi-tenant) bir B2B SaaS platformunun tüm mimari, ürün, analiz, mühendislik, DevOps ve teknik destek süreçlerini uçtan uca belgeleyen kapsamlı bir başvuru kaynağıdır.

---

## 📚 Final PDF Kitaplar / Final PDF Publications

| Dil / Language | Kitap Adı / Publication Title | PDF Dosyası / Artifact Link |
| :--- | :--- | :--- |
| **Türkçe (TR)** | *NexusCloud SaaS: CTO'dan Junior Mühendise, DDD ve Çevik Scrum ile Sıfırdan Zirveye Yazılım Yaşam Döngüsü* | [NexusCloud_SaaS_DDD_Agile_Kitap_TR.pdf](file:///Users/aliturgutbozkurt/Desktop/Agile-DDD-Saas-Example-Team/dist_pdf/NexusCloud_SaaS_DDD_Agile_Kitap_TR.pdf) |
| **English (EN)** | *NexusCloud SaaS: From CTO to Junior Engineer — Enterprise Software Engineering Playbook with DDD & Agile Scrum* | [NexusCloud_SaaS_DDD_Agile_Playbook_EN.pdf](file:///Users/aliturgutbozkurt/Desktop/Agile-DDD-Saas-Example-Team/dist_pdf/NexusCloud_SaaS_DDD_Agile_Playbook_EN.pdf) |

---

## 🛠️ Zorunlu Teknoloji Yığını / Prescribed Technology Stack

- **Backend:** Java 21, Spring Boot 3.3.x, Spring Cloud (Gateway, Resilience4j Circuit Breaker, Config)
- **Veritabanı (Database & Storage):** PostgreSQL 16 (Row-Level Security - RLS, dinamik şema izolasyonu, Flyway migrations)
- **Önbellek (Cache):** Redis 7 (Google Cloud Memorystore L2 Cache-Aside & Token Bucket rate limiting)
- **Arama & Log Analitiği (Search):** Elasticsearch 8.x (Kiracı bazlı denetim logları, tam metin adli arama)
- **Olay Akışı (Event Streaming):** Apache Kafka (TenantId partition anahtarıyla sıralı olay işleme, Outbox Pattern)
- **Ön Yüz (Frontend):** Next.js 15 (App Router, React Server Components, TypeScript, Tailwind CSS)
- **Bulut Altyapısı (Cloud):** Google Cloud Platform - GCP (GKE, Cloud SQL, Memorystore, Cloud Armor, Secret Manager)
- **Dağıtım (Deployment):** Google Kubernetes Engine (GKE), Helm, HPA, Zero-Downtime Rolling Update
- **CI/CD Boru Hattı:** GitHub Actions (Çok aşamalı lint, test, güvenlik taraması, Docker ve GKE dağıtımı)

---

## 👥 Kapsanan Roller ve Ekipler / Covered Roles & Teams

### Çapraz Fonksiyonel Ekipler (Squads - Team Topologies):
1. **Squad Alpha (Identity & Core Multi-Tenancy):** Kiracı provizyonu, SSO/SAML, RBAC.
2. **Squad Beta (Billing & Monetization):** Abonelikler, kullanım kotası, ödeme geçitleri, dunning.
3. **Squad Gamma (Workflow Core Engine):** Dağıtık durum makineleri, olay işleyicileri, Kafka akışları.
4. **Squad Delta (Customer Experience & Web):** Next.js 15 portalı, görsel tasarımcı, tasarım sistemi.
5. **Squad Epsilon (DevOps, SRE & Platform Engineering):** GKE kümeleri, Terraform IaC, Prometheus/Grafana alarmları.
6. **Müşteri Başarısı ve Canlı Destek (L1 / L2):** 24/7 bilet triyajı, Elasticsearch log araştırması, L3 eskalasyonu.

### Bireysel Roller (Junior'dan CTO'ya, Analizden Desteğe):
- **CTO (Chief Technology Officer):** Teknoloji vizyonu, FinOps bulut bütçesi, %99.95 SLA, SOC 2 uyumluluğu.
- **Baş Yazılım Mimarı (Principal Architect):** DDD sınırları, Bounded Context Map, ADR yönetimi, Kafka şemaları.
- **Mühendislik Müdürü (Engineering Manager):** 1-on-1 görüşmeleri, kariyer merdiveni, sprint kapasitesi.
- **Ürün Sahibi (PO) & İş Analisti (BA):** Backlog yönetimi, Gherkin BDD (`Given-When-Then`) kabul kriterleri, Event Storming.
- **Scrum Master (SM) & Çevik Koç:** Scrum seremonileri, velocity/burn-down takibi, Scrum of Scrums.
- **Kıdemli / Lider Mühendis (Senior / Lead):** Rich domain aggregate tasarımı, PR incelemeleri, Junior mentörlüğü.
- **Orta Seviye Mühendis (Mid-Level):** Bağımsız use-case geliştirme, Testcontainers entegrasyon testleri.
- **Junior Mühendis (Junior Engineer):** Value Object geliştirme, TDD birim testleri, 30-60-90 gün onboarding.
- **UI/UX Tasarımcısı:** Figma bileşenleri, tasarım tokenları, WCAG AA erişilebilirlik.
- **QA & Test Otomasyon Mühendisi:** Test piramidi, Pact sözleşme testleri, Playwright E2E testleri.
- **DevOps & SRE Mühendisi:** Kubernetes HPA, Terraform, GitHub Actions, hata bütçesi (Error Budget).
- **Bilgi Güvenliği Mühendisi (SecOps):** OWASP Top 10, kiracı veri izolasyonu testleri, Secret Manager.
- **L1 / L2 Teknik Destek Mühendisi:** Bilet eskalasyonu, log adli analizi, Sev-1 kriz yönetimi.

---

## 📑 Döküman İndeksi / Documentation Index

### Türkçe Dokümanlar (`docs/tr/`):
1. [01. Senaryo, Şirket Vizyonu ve B2B İş Modeli](file:///Users/aliturgutbozkurt/Desktop/Agile-DDD-Saas-Example-Team/docs/tr/01_senaryo_ve_is_modeli.md)
2. [02. Organizasyon Yapısı, Ekipler ve Roller](file:///Users/aliturgutbozkurt/Desktop/Agile-DDD-Saas-Example-Team/docs/tr/02_organizasyon_ekipler_ve_roller.md)
3. [03. DDD Stratejik Tasarım ve Event Storming](file:///Users/aliturgutbozkurt/Desktop/Agile-DDD-Saas-Example-Team/docs/tr/03_ddd_stratejik_tasarim_ve_event_storming.md)
4. [04. DDD Taktiksel Tasarım ve Mimari İlkeler](file:///Users/aliturgutbozkurt/Desktop/Agile-DDD-Saas-Example-Team/docs/tr/04_ddd_taktiksel_tasarim_ve_mimari.md)
5. [05. Teknoloji Yığını ve Uçtan Uca Mimari Tasarım](file:///Users/aliturgutbozkurt/Desktop/Agile-DDD-Saas-Example-Team/docs/tr/05_teknoloji_yigini_mimari_tasarim.md)
6. [06. Çevik Scrum Yaşam Döngüsü ve Sprint Süreçleri](file:///Users/aliturgutbozkurt/Desktop/Agile-DDD-Saas-Example-Team/docs/tr/06_agile_scrum_ve_sprint_dongusu.md)
7. [07. DevOps, GCP, Kubernetes ve CI/CD Pipeline Mimarisi](file:///Users/aliturgutbozkurt/Desktop/Agile-DDD-Saas-Example-Team/docs/tr/07_devops_gcp_kubernetes_ci_cd.md)
8. [08. Kalite Güvencesi (QA), Test Piramidi ve Güvenlik](file:///Users/aliturgutbozkurt/Desktop/Agile-DDD-Saas-Example-Team/docs/tr/08_qa_test_piramidi_ve_guvenlik.md)
9. [09. Teknik Destek (L1/L2), Olay (Incident) ve Kriz Yönetimi](file:///Users/aliturgutbozkurt/Desktop/Agile-DDD-Saas-Example-Team/docs/tr/09_teknik_destek_l1_l2_ve_incident_yonetimi.md)
10. [10. Junior Mühendisin Saha Rehberi ve Kariyer Yolculuğu](file:///Users/aliturgutbozkurt/Desktop/Agile-DDD-Saas-Example-Team/docs/tr/10_junior_muhendis_rehberi_ve_kariyer.md)

### English Documentation (`docs/en/`):
1. [01. SaaS Scenario, Company Vision, and Business Model](file:///Users/aliturgutbozkurt/Desktop/Agile-DDD-Saas-Example-Team/docs/en/01_scenario_and_business_model.md)
2. [02. Organization Structure, Teams, and Roles](file:///Users/aliturgutbozkurt/Desktop/Agile-DDD-Saas-Example-Team/docs/en/02_organization_teams_and_roles.md)
3. [03. DDD Strategic Design and Event Storming](file:///Users/aliturgutbozkurt/Desktop/Agile-DDD-Saas-Example-Team/docs/en/03_ddd_strategic_design_and_event_storming.md)
4. [04. DDD Tactical Design & Architectural Patterns](file:///Users/aliturgutbozkurt/Desktop/Agile-DDD-Saas-Example-Team/docs/en/04_ddd_tactical_design_and_architecture.md)
5. [05. Technology Stack & Architectural Blueprint](file:///Users/aliturgutbozkurt/Desktop/Agile-DDD-Saas-Example-Team/docs/en/05_technology_stack_architectural_design.md)
6. [06. Agile Scrum Lifecycle and Sprint Execution](file:///Users/aliturgutbozkurt/Desktop/Agile-DDD-Saas-Example-Team/docs/en/06_agile_scrum_and_sprint_lifecycle.md)
7. [07. DevOps, GCP, Kubernetes, and CI/CD Pipeline Architecture](file:///Users/aliturgutbozkurt/Desktop/Agile-DDD-Saas-Example-Team/docs/en/07_devops_gcp_kubernetes_ci_cd.md)
8. [08. Quality Assurance (QA), Test Pyramid, and Security](file:///Users/aliturgutbozkurt/Desktop/Agile-DDD-Saas-Example-Team/docs/en/08_qa_test_pyramid_and_security.md)
9. [09. Technical Support (L1/L2), Incident Ops, and Crisis Management](file:///Users/aliturgutbozkurt/Desktop/Agile-DDD-Saas-Example-Team/docs/en/09_technical_support_l1_l2_incident_mgmt.md)
10. [10. The Junior Engineer's Field Guide and Career Acceleration](file:///Users/aliturgutbozkurt/Desktop/Agile-DDD-Saas-Example-Team/docs/en/10_junior_engineer_playbook_and_career.md)

---

## ⚡ PDF Kitapları Yeniden Derleme / Recompiling PDF Books

PDF kitaplarını dilediğiniz zaman tek komutla yeniden derleyebilirsiniz:
```bash
./book_typst/compile_books.sh
```
veya doğrudan Typst kullanarak:
```bash
typst compile book_typst/book_tr.typ dist_pdf/NexusCloud_SaaS_DDD_Agile_Kitap_TR.pdf
typst compile book_typst/book_en.typ dist_pdf/NexusCloud_SaaS_DDD_Agile_Playbook_EN.pdf
```
