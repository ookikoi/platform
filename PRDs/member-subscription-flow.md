# PRD: Member Subscription & Access Flow

**Status:** Approved  
**Date:** 2026-04-01  
**Owner:** Platform Team  
**Stakeholders:** Membership, Product, Billing

---

## Overview

This document specifies the cross-platform flow for membership subscriptions and entitlements. New members should be able to sign up, access tier-specific features, and use the member dashboard to manage their subscription.

---

## User Journey

```
Signup → Confirm Email → Select Tier → Payment → Activate Member Access → Dashboard
```

---

## Services Required

These services need to exist and be deployed in order:

| Service                       | Type   | Purpose                            |
| ----------------------------- | ------ | ---------------------------------- |
| `member-subscribe-api`        | Lambda | Create member + payment initiation |
| `member.subscription.created` | Event  | Notifies downstream systems        |
| `subscription-notification`   | Lambda | Sends welcome email                |
| `member-access-control`       | Lambda | Evaluates member entitlements      |
| `dashboard-api`               | Lambda | Serves member dashboard data       |

---

## Acceptance Criteria

- [ ] New member can submit signup form with email, name, password
- [ ] Email confirmation required before subscription
- [ ] Member tier selection (Basic, Premium, Expert)
- [ ] Payment processed via Stripe
- [ ] Upon successful payment, `member.subscription.created` event emitted
- [ ] Welcome email sent within 2 minutes
- [ ] Member dashboard accessible, showing subscription details
- [ ] Tier determines access to: reviews, expert advice, priority support

---

## Platform Dependencies

- **Cognito**: Member authentication
- **DynamoDB**: Member profiles, subscriptions
- **EventBridge**: Subscription events
- **Email Service**: Welcome + payment confirmations

---

## Success Metrics

- Signup-to-active: < 5 minutes
- Email delivery: < 2 minutes
- Member dashboard load: < 1 second
- 99.9% uptime
