# Chapter 6: Agile Scrum Lifecycle and Sprint Execution

## 6.1 Sprint 0: Infrastructure, Tooling, and Working Agreements
Before writing business logic, all squads completed a 2-week foundational **Sprint 0**.

### Sprint 0 Deliverables:
1. **Developer Environment Standard:** One-command local spin-up via Docker Compose (`make local-up`) including PostgreSQL 16, Redis 7, Kafka, and Elasticsearch.
2. **Team Working Agreements:**
   - Deep work block every morning until 10:00 AM (no scheduled meetings).
   - PR review turnaround SLA: maximum 4 business hours.
   - Zero commits to `main` without automated test coverage and passing linter gates.
   - Red CI/CD pipelines represent the squad's number-one shared priority ("Stop the line").

---

## 6.2 Definition of Ready (DoR) and Definition of Done (DoD)

### Definition of Ready (DoR):
A User Story may only enter Sprint Planning when:
- [ ] Business value and target user persona are explicitly documented.
- [ ] At least two Gherkin BDD acceptance criteria (`Given`, `When`, `Then`) are defined.
- [ ] Figma component designs and responsive specifications are linked.
- [ ] Database schema migrations and inter-service API impacts are identified.
- [ ] The squad has estimated story points via Planning Poker.

### Definition of Done (DoD):
A User Story is considered shippable to production when:
- [ ] Domain layer unit test coverage exceeds 85%.
- [ ] Real-container integration tests (Testcontainers) pass for PostgreSQL and Kafka.
- [ ] SonarQube analysis reports 0 Security Hotspots and Quality Gate "Passed".
- [ ] At least two senior engineers approve the Pull Request.
- [ ] OpenAPI / Swagger documentation is automatically synchronized.
- [ ] Automated staging smoke tests execute with zero failures.

---

## 6.3 User Story Blueprint with Gherkin BDD Specifications

### User Story Example:
**ID:** `NEXUS-204`  
**Title:** Self-Service Tenant Subscription Plan Upgrade to Professional  
**Effort:** 5 Story Points  
**Squad:** Squad Beta (Billing & Monetization)  

```gherkin
Feature: Subscription Plan Upgrade

  Scenario: Active Starter tenant upgrades to Professional tier
    Given A tenant with ID "tenant-acme-corp" and subscription status "ACTIVE"
    And Current plan tier is "STARTER"
    When The tenant requests an upgrade to "PROFESSIONAL"
    Then The subscription status must remain "ACTIVE"
    And The active plan tier must be updated to "PROFESSIONAL"
    And A "PlanUpgradedEvent" must be emitted to Kafka topic "nexus.billing.subscription-events.v1"
    And The new execution quota of 100,000 must immediately update in Redis cache
    And A confirmation receipt email must be dispatched to the tenant admin

  Scenario: Tenant attempts to upgrade a cancelled subscription
    Given A tenant with subscription status "CANCELLED"
    When The tenant requests a plan upgrade
    Then The system must reject the request with HTTP 422 Unprocessable Entity
    And The error message must state "Cancelled subscriptions cannot be upgraded"
```

---

## 6.4 Effort Estimation: Planning Poker & Fibonacci Sequence
Squads utilize Fibonacci story points to capture relative complexity, uncertainty, and scope:
- **1-2 Points:** Low-risk, well-understood tasks (e.g., adding a self-validating Value Object, adjusting log format).
- **3-5 Points:** Standard feature stories with database mutations, API contracts, and integration tests.
- **8 Points:** High-uncertainty stories spanning multiple services or third-party webhooks.
- **13+ Points:** Epic-level scope; must be decomposed into smaller user stories prior to sprint commitment.

---

## 6.5 Two-Week Sprint Walkthrough

### Day 1 (Monday): Sprint Planning
- **Goal:** PO outlines the Sprint Goal: *"Enable tenant self-service tier upgrades with real-time Redis quota cache updates."*
- Squad pulls stories matching historical velocity (average: 38 story points) into the Sprint Backlog and breaks them into engineering sub-tasks.

### Days 2 - 9: Daily Scrum & Engineering Cadence
- **Time:** 09:45 AM (Strict 15-minute timebox, standing up).
- **Three Questions:** What did I accomplish yesterday? What will I do today? What blockers exist?
- **Junior Mentorship in Action:** A junior engineer reports uncertainty regarding cross-currency arithmetic validation in the `Money` Value Object. A senior engineer schedules an afternoon pairing session to guide the design.

### Day 5 (Friday): Backlog Refinement
- Squad reviews candidate stories for the upcoming sprint, answers technical spikes, and refines acceptance criteria.

### Day 10 (Friday): Sprint Review & Stakeholder Demo
- Live demonstration in staging for all stakeholders, the CTO, and product leaders. No slides—working software only.

### Day 10 (Friday): Sprint Retrospective
- **Framework:** 4L (Liked, Learned, Lacked, Longed for).
- Actionable improvement agreed: *"Testcontainers initialization time increased. Enable reusable container flags across CI test runners."*

---

## 6.6 Cross-Squad Synchronization: Scrum of Scrums
Twice weekly (Tuesday & Thursday), Scrum Masters and the Principal Architect convene for a 20-minute **Scrum of Scrums**:
- Cross-squad dependencies are reviewed (e.g., Billing Squad notifying Workflow Squad of new event schemas).
- Shared platform maintenance windows (e.g., GKE node pool patching) are communicated and coordinated.
