# Chapter 10: The Junior Engineer's Field Guide & Career Acceleration

## 10.1 Structured 30-60-90 Day Onboarding Roadmap
At Nexus Digital Systems, junior engineer progression is guided by intentional mentorship and milestone roadmaps:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        JUNIOR ONBOARDING ROADMAP                       │
│                                                                        │
│   DAYS 1 - 30: ORIENTATION & FIRST CONTRIBUTIONS                       │
│   • Spin up local environment via Docker Compose                       │
│   • Master the Ubiquitous Language and domain glossary                 │
│   • Implement a self-validating Value Object and merge first PR        │
│                                                                        │
│   DAYS 31 - 60: AUTONOMY & PAIRING                                     │
│   • Deliver an entire User Story from refinement to production         │
│   • Write integration tests with Testcontainers                        │
│   • Attend twice-weekly pairing sessions with a Senior Engineer        │
│                                                                        │
│   DAYS 61 - 90: DEEPENING & SHADOW ON-CALL                             │
│   • Implement a Kafka consumer or Redis caching strategy               │
│   • Shadow L2/L3 on-call rotations during live production incidents    │
│   • Host an internal technical sharing session (Lunch & Learn)         │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 10.2 Deconstructing a User Story into Clean Code
When a junior engineer claims a story from the sprint backlog:

1. **Step 1: Clarify Acceptance Criteria:** Reads Gherkin specifications (`Given`, `When`, `Then`). Flags ambiguities with the PO during refinement.
2. **Step 2: Model Domain Invariants:** Identifies whether the story touches an existing Aggregate Root, requires a new Value Object, or modifies an application service.
3. **Step 3: Test-Driven Development (TDD):** Writes the failing unit test first. Watches it fail for the right reason.
4. **Step 4: Minimal Implementation:** Writes the cleanest code necessary to pass the test.
5. **Step 5: Refactor & Clean:** Refactors for readability, removes dead code, and adheres to DDD boundaries.

---

## 10.3 Git Branching & Conventional Commits
- **Branch Naming Standard:**  
  `feature/NEXUS-204-subscription-plan-upgrade` or `fix/NEXUS-310-redis-ttl-leak`
- **Conventional Commits Standard:**
  - `feat(billing): add SubscriptionPlan value object validation`
  - `test(subscription): add unit tests for invariant cancellation check`
  - `fix(kafka): resolve consumer deserialization error on null tenantId`
  - `docs(readme): update local docker-compose run instructions`

---

## 10.4 Crafting the Perfect Pull Request (PR) & Navigating Code Reviews

### Junior PR Checklist:
- [ ] Atomic scope (ideal: < 250 lines changed).
- [ ] Clear description outlining: What was done, Why it was done, and How it was tested.
- [ ] All unit and integration tests pass locally (`mvn clean test`).
- [ ] Screenshot or execution log attached.

### Interpreting Senior Code Reviews:
- Senior feedback is a technical investment in your craft, never a personal critique.
- Clarify questions with curiosity: *"Could you explain the architectural advantages of this approach versus the alternative?"*
- Once edits are committed, mark discussions resolved and notify the reviewer.

---

## 10.5 Pair Programming Best Practices
- **Roles:** The Junior operates as the **Driver** (hands on the keyboard); the Senior operates as the **Navigator** (guiding strategy and architecture).
- **The 15-Minute Rule:** Before escalating a blocker, investigate for 15 minutes by checking logs, traces, and documentation. When asking for assistance, frame the question with context:
  > *"I am implementing X. I encountered error Y. I investigated hypotheses A and B without success. Could you guide my next debugging step?"*

---

## 10.6 The Engineering Career Ladder
Promotion milestones at Nexus Digital Systems:

| Competency Pillar | Junior Engineer | Mid-Level Engineer | Senior / Lead Engineer |
| :--- | :--- | :--- | :--- |
| **Autonomy** | Requires guidance on design and boundaries. | Delivers stories independently with high quality. | Leads technical vision; navigates deep ambiguity. |
| **Architecture** | Implements Value Objects and controllers. | Applies Hexagonal Architecture and CQRS reliably. | Defines Bounded Contexts; authors ADRs. |
| **Debugging** | Diagnoses local stack traces. | Traces issues across Elasticsearch and OpenTelemetry. | Acts as Incident Commander during live Sev-1 crises. |
| **Impact** | Focuses on personal task completion. | Elevates squad code quality and delivery speed. | Sets organization-wide standards; mentors across teams. |
