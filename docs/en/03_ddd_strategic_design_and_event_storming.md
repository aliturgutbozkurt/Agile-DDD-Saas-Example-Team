# Chapter 3: Domain-Driven Design (DDD) Strategic Design and Event Storming

## 3.1 Problem Space vs. Solution Space
Before writing a single line of backend infrastructure, Nexus Digital Systems' leadership decoupled the **Problem Space** from the **Solution Space**.

```
┌────────────────────────────────────────────────────────────────────────┐
│                        PROBLEM SPACE (BUSINESS)                        │
│                                                                        │
│  ┌──────────────────────┐  ┌────────────────────┐  ┌────────────────┐  │
│  │     CORE DOMAIN      │  │ SUPPORTING DOMAIN  │  │ GENERIC DOMAIN │  │
│  │ Distributed Workflow │  │ Multi-Tenant       │  │ Authentication │  │
│  │ Orchestration Engine │  │ Subscription & Pay │  │ Notifications  │  │
│  └──────────────────────┘  └────────────────────┘  └────────────────┘  │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Strategic Translation
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                        SOLUTION SPACE (SOFTWARE)                       │
│                                                                        │
│  ┌──────────────────────┐  ┌────────────────────┐  ┌────────────────┐  │
│  │  WORKFLOW CONTEXT    │  │  BILLING CONTEXT   │  │ IDENTITY CTX   │  │
│  │ (Java + Kafka + ES)  │  │ (Java + Postgres)  │  │ (Spring Sec)   │  │
│  └──────────────────────┘  └────────────────────┘  └────────────────┘  │
└────────────────────────────────────────────────────────────────────────┘
```

### Subdomain Taxonomy:
1. **Core Domain (Workflow Orchestration Engine):**
   - The primary commercial differentiator. Offers complex distributed state management, conditional branch evaluation, and distributed event triggers. Custom-built from the ground up by senior engineers.
2. **Supporting Subdomains (Subscription & Multi-Tenancy):**
   - Critical for business viability, enforcing tenant provisioning and subscription tiers. Custom-built to support proprietary SaaS pricing logic.
3. **Generic Subdomains (Identity, Notifications, Audit Logging):**
   - Standardized problems (OAuth2, SendGrid emails, Cloud Logging). Solved using established open-source libraries and cloud services.

---

## 3.2 Event Storming Workshop & Timeline
During Sprint 0, a 3-day **Event Storming** workshop brought together business stakeholders, architects, developers, QA, and support personnel.

### Sticky Color Conventions:
- **Orange (Domain Event):** Past-tense business fact (`SubscriptionCreated`, `WorkflowExecuted`).
- **Blue (Command):** User-triggered intent (`CreateSubscription`, `TriggerWorkflow`).
- **Yellow (Aggregate Root):** Consistency boundary enforcing invariants (`Subscription`, `WorkflowExecution`).
- **Green (Read Model):** Projection supporting user decision-making (`TenantBillingSummaryView`).
- **Pink (External System):** External boundary (`Stripe API`, `SendGrid`).
- **Red (Hotspot):** Unresolved business conflict or architectural risk (`"What is the dunning grace period before hard suspension?"`).

### Discovered Lifecycle Timeline:
1. `TenantRegistered` ➔ `TrialSubscriptionProvisioned` ➔ `DefaultWorkflowCreated`
2. `WorkflowTriggerReceived` ➔ `TenantQuotaChecked` ➔ `WorkflowExecutionStarted`
3. `StepExecutedSuccessfully` ➔ `WorkflowExecutionCompleted` ➔ `ExecutionMetered`
4. `BillingCycleEnded` ➔ `InvoiceGenerated` ➔ `PaymentChargedViaStripe` ➔ `SubscriptionRenewed`
5. *(Hotspot Handling)*: `PaymentFailed` ➔ `GracePeriodStarted` ➔ `DunningEmailSent` ➔ *(After 7 days)* `SubscriptionSuspended`

---

## 3.3 Ubiquitous Language Glossary
A shared, unambiguous domain vocabulary used across all documentation, Jira tickets, and Java code:

| Term (EN) | Term (TR) | Bounded Context | Formal Specification & Business Rule |
| :--- | :--- | :--- | :--- |
| **Tenant** | **Kiracı** | Identity & Core | Independent organization utilizing the platform with dedicated logical/physical isolation. |
| **Subscription** | **Abonelik** | Billing Context | Contract granting platform capabilities and execution quotas over a discrete billing period. |
| **Plan Tier** | **Plan Seviyesi** | Billing Context | Predefined package (Starter, Professional, Enterprise) dictating SLA, quotas, and pricing. |
| **Workflow** | **İş Akışı** | Workflow Context | Configured state machine comprised of triggers, conditional evaluations, and sequential steps. |
| **Execution** | **Yürütme** | Workflow Context | A discrete runtime invocation of a workflow, tracked for metering and SLA compliance. |
| **Metered Usage** | **Kullanım Ölçümü**| Billing Context | Dynamic counter recording execution units and data volume for monthly invoice calculations. |
| **Suspension** | **Askıya Alma** | Billing Context | Operational state prohibiting execution due to non-payment or security policy breaches. |
| **Outbox** | **Olay Yolu** | Shared Kernel | Database-backed persistence buffer guaranteeing atomic publication of events to Kafka. |

---

## 3.4 Bounded Contexts and Context Mapping
NexusCloud is divided into distinct, loosely-coupled Bounded Contexts:

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
                 │                                                │ WORKFLOW ENGINE  │
                 ▼                                                │   CORE CONTEXT   │
┌─────────────────────────────────┐                               │  (Core Domain)   │
│      NOTIFICATION CONTEXT       │◄──────────────────────────────┤                  │
│       (Generic Subdomain)       │  Events (StepFailed, Alert)   └──────────────────┘
└─────────────────────────────────┘
```

### Context Relationships:
1. **Upstream / Downstream (Customer-Supplier):** Identity Context is Upstream; Subscription Context is Downstream. Subscription depends on valid Tenant IDs.
2. **Anti-Corruption Layer (ACL):** The Workflow Core Engine does not bind to external billing schemas. It uses an internal ACL adapter translating external billing events into localized `QuotaPolicy` invariants.
3. **Open Host Service (OHS) / Published Language (PL):** Identity Context exposes standardized JSON-Schema payloads over Kafka topics.
4. **Separate Ways:** The Elasticsearch search and analytics engine operates as an independent Read Projection, completely decoupled from operational transactional databases.
