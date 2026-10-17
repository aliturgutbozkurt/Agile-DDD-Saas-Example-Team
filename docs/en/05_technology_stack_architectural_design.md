# Chapter 5: Technology Stack & Architectural Blueprint

## 5.1 Technology Blueprint Overview
The NexusCloud technology stack combines high-throughput enterprise components selected for zero data loss, strict multi-tenant isolation, and sub-150ms p99 response times.

```
                    ┌────────────────────────────┐
                    │      GCP CLOUD ARMOR       │ (DDoS & WAF Mitigation)
                    └─────────────┬──────────────┘
                                  │
                                  ▼
                    ┌────────────────────────────┐
                    │  GCP CLOUD LOAD BALANCER   │ (SSL Termination & Ingress)
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
│                                          DATA & STREAMING PLANE                                             │
│                                                                                                             │
│  ┌──────────────────────┐  ┌──────────────────────┐  ┌──────────────────────┐  ┌─────────────────────────┐  │
│  │   POSTGRESQL 16      │  │      REDIS 7         │  │   ELASTICSEARCH 8    │  │      APACHE KAFKA       │  │
│  │ Cloud SQL (RLS/Flyway│  │ Memorystore L2 Cache │  │ Tenant Audit/Search  │  │ Distributed Event Bus   │  │
│  └──────────────────────┘  └──────────────────────┘  └──────────────────────┘  └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 5.2 Backend: Java 21, Spring Boot 3, and Spring Cloud
- **Java 21 Virtual Threads (Project Loom):** High-concurrency throughput with non-blocking virtual threads handling tens of thousands of simultaneous tenant HTTP requests without thread pool starvation.
- **Spring Boot 3.3.x:** Native integration with Jakarta EE 10, Spring Data 3, and Micrometer Prometheus metrics.
- **Spring Cloud Gateway:** Centralized ingress routing, JWT validation, and distributed rate limiting.
- **Resilience4j:** Circuit breakers isolate external billing and webhook failures, preventing cascading system degradation.

---

## 5.3 Database & Storage: PostgreSQL 16
Hosted on Google Cloud SQL with automated failover and daily backups.

### Row-Level Security (RLS) Configuration:
```sql
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation_policy ON subscriptions
    FOR ALL
    USING (tenant_id = current_setting('app.current_tenant_id', true));
```
Every query issued by Spring Data JPA implicitly inherits this restriction, preventing cross-tenant data leaks at the database engine level.

---

## 5.4 Caching: Redis 7 (Google Cloud Memorystore)
- **L2 Cache-Aside Pattern:** High-frequency tenant subscription profiles and workflow execution states are cached in Redis with a 1-hour TTL. Over 94% of read requests resolve in memory (< 2 ms).
- **Rate Limiting:** Token-bucket algorithms enforce strict request quotas per subscription tier.
- **Distributed Locking:** Redlock ensures workflows cannot be executed concurrently by duplicate webhooks.

---

## 5.5 Full-Text Search & Audit Analytics: Elasticsearch 8.x
- **Forensic Ingestion:** All execution step inputs, outputs, errors, and billing audit trails are indexed into `nexus-subscription-audit` and `nexus-workflow-audit`.
- **Support Acceleration:** L1/L2 support engineers leverage Elasticsearch to locate failed tenant events in sub-50ms query times using customer-provided transaction IDs.

---

## 5.6 Streaming & Event Sourcing: Apache Kafka
- **Partitioning by Tenant:** All events leverage `tenantId` as the record key, guaranteeing in-order event processing within dedicated partitions per tenant.
- **Schema Governance:** Kafka Schema Registry ensures backward and forward schema compatibility across service revisions.
- **Dead-Letter Queue (DLQ):** Unparseable or poisoned messages are automatically routed to DLQ topics with alerting for SRE review.

---

## 5.7 Frontend: Next.js 15
- **App Router & Server Components:** Hybrid rendering (SSR and ISR) reduces initial bundle size and accelerates time-to-interactive (< 800 ms).
- **Multi-Tenant Routing:** Dynamic paths (`app/[tenant]/...`) extract tenant identity securely on the server side.
- **Design System:** Built using Tailwind CSS, adhering to WCAG AA accessibility and supporting responsive dark/light modes.

---

## 5.8 Cloud Platform: Google Cloud Platform (GCP)
- **Google Kubernetes Engine (GKE):** Multi-zone high-availability cluster running containerized workloads.
- **Google Cloud Armor:** Enterprise DDoS mitigation and Web Application Firewall (WAF) filtering.
- **GCP Secret Manager:** Runtime retrieval of database passwords and API tokens via Workload Identity Federation.
