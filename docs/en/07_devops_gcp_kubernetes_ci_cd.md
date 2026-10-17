# Chapter 7: DevOps, GCP, Kubernetes, and CI/CD Pipeline Architecture

## 7.1 Google Cloud Platform (GCP) Infrastructure Design
NexusCloud relies on multi-zone, high-availability architecture across Google Cloud region `us-central1`.

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
│            │         MANAGED HA DATA SERVICES (GCP)        │           │
│            │  • Cloud SQL PostgreSQL 16 (HA Failover Node) │           │
│            │  • Memorystore for Redis (Replicated Cluster) │           │
│            │  • GCP Secret Manager & KMS Entegrasyonu      │           │
│            └───────────────────────────────────────────────┘           │
└────────────────────────────────────────────────────────────────────────┘
```

### Infrastructure as Code (Terraform):
All network topologies (VPCs, subnets, firewall rules), GKE clusters, Cloud SQL instances, and IAM service bindings are version-controlled in Terraform modules. Manual console modifications are strictly forbidden.

---

## 7.2 Google Kubernetes Engine (GKE) Cluster Architecture
- **Workload Identity Federation:** Eliminates static service account keys. GKE Pod ServiceAccounts impersonate GCP IAM roles dynamically via OpenID Connect tokens.
- **Horizontal Pod Autoscaling (HPA):** Pod replicas autoscale from 3 to 15 based on CPU (> 70%), memory (> 80%), and Kafka consumer lag via KEDA.
- **Zero-Downtime Rolling Deployments:** Configured with `maxSurge: 1` and `maxUnavailable: 0` paired with Spring Boot Actuator readiness and liveness probes.

---

## 7.3 Multi-Stage GitHub Actions Pipeline

```
[ Push / PR Event ]
       │
       ▼
┌────────────────────────────────────────────────────────┐
│ 1. Static Analysis & Security Gate                     │
│    • Checkstyle • SonarQube Quality Gate • Trivy FS    │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ 2. Automated Test Execution (Testcontainers)           │
│    • JUnit 5 Units • PostgreSQL Real Container Test    │
│    • Apache Kafka Event Integration Tests              │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ 3. Container Build & Packaging                         │
│    • Multi-stage Docker Build (Alpine Temurin 21)      │
│    • Push to Google Artifact Registry via WIF Auth     │
└──────────────────────────┬─────────────────────────────┘
                           │ (Triggered on 'main' merge only)
                           ▼
┌────────────────────────────────────────────────────────┐
│ 4. Kubernetes Deployment & Rollout Verification        │
│    • kubectl apply -f k8s/                             │
│    • kubectl rollout status --timeout=180s             │
│    • Automated Synthetic Smoke Test Verification       │
└────────────────────────────────────────────────────────┘
```

---

## 7.4 The Three Pillars of Observability

### 1. Metrics (Prometheus & Grafana):
- Exported via Spring Boot Actuator `/actuator/prometheus`.
- Dashboards track: HTTP latency percentiles (p50, p95, p99), HikariCP database connection pool saturation, Redis cache hit ratios, and Kafka consumer group lags.

### 2. Logging (Structured JSON & Elasticsearch):
- Standardized format across all microservices:
  `{"timestamp": "...", "level": "INFO", "tenantId": "...", "traceId": "...", "spanId": "...", "message": "..."}`.
- Fast log forensics in Kibana using tenant IDs and correlation trace IDs.

### 3. Distributed Tracing (OpenTelemetry & Jaeger):
- W3C Trace Context headers propagate across the Next.js frontend, Spring Cloud Gateway, backend services, Kafka records, and database queries.
- Engineers pinpoint latency bottlenecks across asynchronous microservice boundaries within Jaeger waterfall traces.

---

## 7.5 Error Budget & SLA Mathematics
A **99.95% Availability SLA** permits an **Error Budget** of 0.05%—translating to a strict maximum of **21.6 minutes of downtime per 30-day month**.
- When a squad consumes > 80% of its monthly error budget, all new feature shipments freeze.
- Engineering capacity pivots 100% toward resilience hardening, query optimization, and technical debt retirement until stability is restored.
