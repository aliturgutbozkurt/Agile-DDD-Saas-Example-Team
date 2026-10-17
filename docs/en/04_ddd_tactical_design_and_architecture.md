# Chapter 4: Domain-Driven Design (DDD) Tactical Design & Architectural Patterns

## 4.1 Hexagonal (Ports & Adapters) Architecture
NexusCloud microservices enforce **Hexagonal Architecture**. The business domain remains isolated from external web protocols, relational databases, cache providers, and messaging buses.

```
┌────────────────────────────────────────────────────────────────────────┐
│                        EXTERNAL WORLD (ADAPTERS)                       │
│                                                                        │
│   [ Next.js UI ] ──► (REST Controller) ─┐                             │
│                                          │                             │
│   [ Kafka Consumer ] ───────────────────┼──► [ DRIVING PORTS ]         │
│                                          │   (Primary Ports)           │
│                                          ▼                             │
│   ┌──────────────────────────────────────────────────────────────┐     │
│   │                 APPLICATION LAYER (USE CASES)                │     │
│   │       Command Handlers • Query Handlers • DTOs               │     │
│   │                              │                               │     │
│   │                              ▼                               │     │
│   │                    CORE DOMAIN LAYER                         │     │
│   │     Aggregates • Entities • Value Objects • Domain Events    │     │
│   │                              │                               │     │
│   │                              ▼                               │     │
│   │                     [ DRIVEN PORTS ]                         │     │
│   │                    (Secondary Ports)                         │     │
│   └──────────────────────────────┬───────────────────────────────┘     │
│                                  │                                     │
│         ┌────────────────────────┼────────────────────────┐            │
│         ▼                        ▼                        ▼            │
│  (PostgreSQL Adapter)     (Redis Cache Adapter)   (Kafka Producer)     │
│  PostgreSQL 16 RLS        Redis L2 Cache          Event Streaming      │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 4.2 Value Objects
Value Objects embody the foundational building blocks of tactical DDD:
1. **No Conceptual Identity:** Value Objects are identified solely by their attributes. If two instances share identical values, they are equal.
2. **Immutability:** Once instantiated, internal state cannot be modified (implemented via Java records or final classes).
3. **Self-Validating:** Invariants are enforced upon construction; an invalid Value Object cannot exist in memory.

### SaaS Instances: `TenantId` and `Money`
- `TenantId`: Guarantees non-blank, sanitized alphanumeric slugs or UUID formats.
- `Money`: Enforces currency homogeneity (preventing accidental additions of USD and EUR without explicit exchange conversion) and round-half-even precision.

---

## 4.3 Entities and Aggregate Roots
An Aggregate represents a cluster of domain entities and value objects treated as a single transactional consistency boundary.

### Rules of Engagement:
- External callers can only hold direct references to the **Aggregate Root**.
- Internal members cannot be directly manipulated from outside the boundary.
- Database transactions commit changes to exactly one aggregate root per unit of work.

### `SubscriptionAggregate` Invariants:
1. **Cancellation Finality:** A cancelled (`CANCELLED`) subscription cannot be upgraded, downgraded, or renewed.
2. **Tenant Uniqueness:** A tenant may possess at most one active or trial subscription concurrently.
3. **Temporal Validity:** The subscription billing period end (`periodEnd`) must strictly succeed the period start (`periodStart`).

---

## 4.4 Domain Events
When an aggregate undergoes a significant business transition, it registers an immutable **Domain Event** (e.g., `SubscriptionCreatedEvent`, `PlanUpgradedEvent`).
- Events are named in the past tense.
- Events record aggregate IDs, tenant keys, and accurate timestamps (`Instant.now()`).

---

## 4.5 Repository Ports and Driven Adapters
- **Domain Layer:** Exposes the interface `ISubscriptionRepository` declaring business query methods without database annotations.
- **Infrastructure Layer:** Implements `PostgresSubscriptionRepositoryAdapter`, managing Spring Data JPA mappings, SQL dialect conversions, and RLS session parameters.

---

## 4.6 Application Services and CQRS
The application service acts as the orchestrator:
- **Command Handling:** Validates incoming DTOs, loads the Aggregate Root via the repository port, invokes business methods, persists changes, and dispatches events.
- **Query Handling:** Skips the domain aggregate for read operations, fetching cached projections directly from Redis or PostgreSQL materialized views.

---

## 4.7 The Dual-Write Dilemma & Transactional Outbox Pattern
Writing to a relational database while simultaneously publishing to an external message broker risks data inconsistency if network partitions occur between the two operations.

```
[ Incoming Command ]
       │
       ▼
┌────────────────────────────────────────────────────────┐
│             ATOMIC POSTGRESQL TRANSACTION              │
│                                                        │
│  1. INSERT INTO subscriptions (id, tenant_id, ...)    │
│  2. INSERT INTO subscription_outbox_events (payload)   │
│                                                        │
│  COMMIT (Both succeed or both roll back together)      │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│          DEBEZIUM CDC / OUTBOX WORKER ENGINE           │
│                                                        │
│  • Polls PENDING records from outbox table             │
│  • Emits to Kafka with TenantId as record key          │
│  • Marks status as PUBLISHED upon broker ACK           │
└────────────────────────────────────────────────────────┘
```

NexusCloud implements the **Transactional Outbox Pattern**:
1. The domain event is serialized and written to the `subscription_outbox_events` table inside the *exact same* ACID database transaction as the aggregate state change.
2. A resilient background process (Debezium Change Data Capture or transactional poller) reads pending records and streams them to Apache Kafka.
3. This guarantees 100% "At-least-once" delivery semantics—zero lost business events.
