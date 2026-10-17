# Chapter 9: Technical Support (L1/L2), Incident Ops, and Crisis Management

## 9.1 Support Tiering & Escalation Matrix
When live production anomalies occur, a structured 3-tier escalation protocol protects core engineering focus while ensuring strict compliance with customer SLA agreements:

```
[ Customer Ticket / Alert ]
             │
             ▼
┌──────────────────────────────────────────────┐
│  L1 CUSTOMER SUPPORT (Helpdesk)              │
│  • Response SLA: < 15 minutes                │
│  • Tasks: Ticket classification, initial     │
│    response, and standard runbook execution  │
└──────────────────────┬───────────────────────┘
                       │ (Technical depth required)
                       ▼
┌──────────────────────────────────────────────┐
│  L2 TECHNICAL SUPPORT (Support Engineers)    │
│  • Response SLA: < 30 minutes                │
│  • Tasks: Elasticsearch log queries,         │
│    OpenTelemetry trace review, tenant audit  │
└──────────────────────┬───────────────────────┘
                       │ (Code defect / Infrastructure outage)
                       ▼
┌──────────────────────────────────────────────┐
│  L3 SQUAD ON-CALL & SRE (Feature Engineers)  │
│  • Response SLA: < 15 minutes (Sev-1)        │
│  • Tasks: Live debugging, hotfix rollout,    │
│    and direct infrastructure mitigation      │
└──────────────────────────────────────────────┘
```

---

## 9.2 Real-World Incident Walkthrough: Sev-1 Critical Outage Simulation

### Incident Case:
**INC-4819: Kafka Consumer Failure & Payment Webhook Backlog**

### Chronology of Events:
- **14:15:** High-volume Black Friday traffic causes payment gateway webhooks to surge to 12,000 requests/sec.
- **14:18:** PagerDuty Alert fires: `KafkaConsumerLagHigh (Topic: nexus.billing.subscription-events.v1 > 15,000 msgs)`.
- **14:20 (L1 Support):** An Enterprise client files an urgent ticket: *"We upgraded to Enterprise plan 15 minutes ago, but our workflow execution quota remains capped."* L1 tags the ticket as Sev-1 and routes it to L2.
- **14:23 (L2 Support):** L2 queries Elasticsearch for tenant logs and observes consumer pods in `CrashLoopBackOff` caused by `OutOfMemoryError: Java heap space`. L2 immediately pages the L3 On-Call Engineer and SRE lead.
- **14:25 (L3 & SRE):** An **Incident Commander** assumes command. A dedicated voice **War Room** opens on Slack. The public status page (`status.nexuscloud.io`) is updated: *"Investigating subscription sync delays."*

---

## 9.3 Mitigation & Resolution
1. **Diagnosis:** Large JSON payloads exceeded JVM heap memory (1024Mi), causing G1GC CPU thrashing and container OOMKilled events.
2. **Mitigation:**
   - SRE increases pod memory limits to 2048Mi and scales the deployment from 3 to 10 replicas:
     `kubectl scale deployment/nexus-subscription-service --replicas=10 -n production`.
   - Redis connection pool size is temporarily expanded to handle the throughput surge.
3. **14:42:** Kafka consumer lag drains to zero. Backlogged webhook events process successfully; tenant quotas update.
4. **14:48:** System operations normalize. Public status page marks all systems operational. Total downtime: **28 minutes**.

---

## 9.4 Root Cause Analysis: The 5 Whys Method
The team conducts a post-incident 5 Whys analysis:

1. **Why did the tenant's quota fail to update?**  
   ➔ Kafka `SubscriptionCreatedEvent` messages were stuck in the backlog.
2. **Why were the messages stuck in the backlog?**  
   ➔ Subscription service consumer pods crashed continuously with OOM errors.
3. **Why did the pods run out of memory?**  
   ➔ The 12,000 burst webhook events exceeded the allocated 1 GB container RAM ceiling.
4. **Why didn't the cluster autoscale before memory exhaustion?**  
   ➔ HPA was coupled only to average CPU metrics, which had not yet crossed the trigger threshold.
5. **Why wasn't Kafka queue lag used for autoscaling?**  
   ➔ KEDA event-driven autoscaler integration was deprioritized in earlier backlog planning.

---

## 9.5 Blameless Post-Mortem & Preventative Action Items
In the engineering culture of Nexus Digital Systems, blame is never assigned to individuals; systemic resilience is strengthened.

| Action Item | Owner | Priority | Target Date |
| :--- | :--- | :--- | :--- |
| Deploy KEDA to GKE cluster for Kafka lag-based autoscaling | SRE Team | P0 (Critical) | 3 Days |
| Optimize JVM container parameters to `-XX:MaxRAMPercentage=75.0` | Lead Backend Dev | P1 (High) | 2 Days |
| Implement Token Bucket rate limiting on Spring Cloud Gateway for webhooks | Senior Backend Dev | P1 (High) | 1 Week |
| Publish Kafka Lag Backlog Triage Runbook for L1/L2 Support | L2 Support Lead | P2 (Medium) | 1 Week |
