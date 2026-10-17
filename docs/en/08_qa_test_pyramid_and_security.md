# Chapter 8: Quality Assurance (QA), Test Pyramid, and Security Architecture

## 8.1 The Enterprise Test Pyramid
Quality Assurance at Nexus Digital Systems is embedded into every development phase rather than staged as an afterthought.

```
                  ┌──────────────┐
                  │  E2E Tests   │  (5%)  Playwright
                  │  (Browser)   │
               ┌──┴──────────────┴──┐
               │   Contract Tests   │  (15%) Pact (Consumer-Driven)
               │   (Integration)    │
            ┌──┴────────────────────┴──┐
            │    Integration Tests     │  (30%) Testcontainers
            │ (Postgres, Kafka, Redis) │
         ┌──┴──────────────────────────┴──┐
         │          Unit Tests            │  (50%) JUnit 5, Mockito
         │  (Domain Aggregates & VOs)     │
         └────────────────────────────────┘
```

---

## 8.2 Test Pyramid Layer Execution

### 1. Unit Tests (JUnit 5 & Mockito):
- Focuses strictly on Domain Aggregates, Entities, and Value Objects.
- Zero network or database I/O; runs within sub-second execution windows.
- TDD Red-Green-Refactor discipline is mandatory for all junior and senior engineers.

### 2. Integration Tests (Testcontainers):
- Spawns real, isolated Docker containers for PostgreSQL 16 and Apache Kafka per test suite.
- Replaces brittle in-memory substitutes (like H2), allowing full validation of PostgreSQL Row-Level Security policies and JSONB operators under real production database engine conditions.

### 3. Contract Tests (Pact):
- Frontend squads publish expected API response schemas as Pact contracts.
- Backend CI pipelines run contract verifications before PR merges, preventing breaking API modifications from reaching staging.

### 4. End-to-End Tests (Playwright):
- Simulates real browser user journeys: tenant signup, subscription plan selection, payment execution, and workflow execution.

### 5. Load and Performance Tests (k6):
- Evaluates system behavior under 5,000 requests per second to ensure p99 latency remains below 150 ms.

---

## 8.3 Enterprise SecOps and Zero-Trust Architecture

### 1. OWASP Top 10 Defenses:
- **Injection Mitigation:** Enforced parameterized JPA queries; string-concatenated SQL queries are flagged as critical vulnerabilities by SonarQube.
- **Broken Object-Level Authorization (BOLA):** Dual-layer defense: Spring Security `@PreAuthorize` combined with PostgreSQL engine-level Row-Level Security (RLS).
- **Vulnerable Dependencies:** Trivy scans container base images and Maven POMs during every CI run.

### 2. Tenant Data Segregation Audits:
- Specialized penetration tests verify that manipulating tenant headers or IDs in API requests yields strict HTTP 403 Forbidden responses with zero data leakage.

### 3. Zero-Hardcoded Secrets Standard:
- Repository commits containing credentials or private keys are blocked pre-commit via TruffleHog.
- All database credentials and third-party API tokens are dynamically resolved from GCP Secret Manager at runtime.
