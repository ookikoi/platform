# PRD: Product Rating Aggregation Pipeline

**Status:** In Progress  
**Date:** 2026-04-01  
**Owner:** Data Platform  
**Stakeholders:** Search, Content, Recommendations

---

## Overview

This document specifies the real-time aggregation of product ratings from member reviews. As reviews are submitted or updated, the core product record must be updated with denormalized rating metrics (average, count, distribution).

This is critical for search relevance, recommendation ranking, and the website's product pages.

---

## Data Model

**Input**: `review.submitted` event

```json
{
  "reviewId": "uuid",
  "productId": "uuid",
  "memberId": "uuid",
  "rating": 4,
  "title": "Excellent value",
  "body": "...",
  "timestamp": "2026-04-01T10:30:00Z"
}
```

**Output**: Update `products` table aggregate

```json
{
  "productId": "uuid",
  "ratingCount": 1243,
  "ratingAverage": 4.2,
  "ratingDistribution": {
    "5": 650,
    "4": 350,
    "3": 150,
    "2": 75,
    "1": 18
  }
}
```

---

## Event Flow

```
EventBridge: review.submitted
  ↓
Lambda: rating-aggregate-event
  ├─→ DynamoDB write: products (aggregate)
  ├─→ DynamoDB write: analytics (hourly snapshot)
  └─→ Emit: product.rating.updated
```

---

## Service Requirements

| Service                        | Type                         | Purpose                            |
| ------------------------------ | ---------------------------- | ---------------------------------- |
| `rating-aggregate-event`       | Lambda (EventBridge trigger) | Consume reviews, update aggregates |
| `analytics-snapshot-scheduled` | Lambda (scheduled, 1h)       | Store hourly snapshots             |
| `product.rating.updated`       | Event                        | Notify search/recommendations      |

---

## Acceptance Criteria

- [ ] Aggregate updates within 500ms of review submission
- [ ] Distribution buckets always sum to ratingCount
- [ ] Handle review updates (re-aggregate on change)
- [ ] Handle review deletions (decrement counts)
- [ ] Scheduler captures hourly snapshots for trend analysis
- [ ] No duplicates if event is replayed

---

## Scalability

- Handle 10,000 reviews/day initially
- Product table has ~50k products
- Peak: 100 reviews/minute (during campaigns)

---

## Rollout Plan

1. Deploy in dev with synthetic reviews
2. Shadow production for 1 week (read-only)
3. Canary: 5% of prod traffic
4. Full rollout
