# Data Platform Architecture

This directory defines the shared data layer used by all platform services.

---

## Resources

```
data-platform/
├── main.tf              # DynamoDB tables, EventBridge, S3
├── variables.tf         # Input variables
└── outputs.tf           # Critical ARNs, table names, event bus
```

---

## DynamoDB Tables

### `members`

Primary key: `memberId` (UUID)

Stores member account data:

```json
{
  "memberId": "uuid",
  "emailAddress": "test@example.com",
  "subscriptionTier": "premium",
  "signupDate": "2026-01-15",
  "lastLogin": "2026-04-01T10:30:00Z",
  "preferences": {
    "emailNotifications": true,
    "newsletter": true
  }
}
```

**Capacity:** On-demand (prod: provisioned 100 RCU/100 WCU)

---

### `reviews`

Primary key: `reviewId` (UUID)  
GSI: `productId-timestamp`

Stores individual product reviews:

```json
{
  "reviewId": "uuid",
  "productId": "uuid",
  "memberId": "uuid",
  "rating": 4,
  "title": "Great product",
  "body": "...",
  "helpful": 45,
  "unhelpful": 3,
  "createdAt": "2026-04-01T10:30:00Z"
}
```

**Capacity:** On-demand (prod: provisioned 50 RCU/200 WCU due to hot writes)

---

### `products`

Primary key: `productId` (UUID)

Stores product metadata + denormalized rating aggregates:

```json
{
  "productId": "uuid",
  "name": "Coffee Maker XYZ",
  "category": "Appliances",
  "ratingAverage": 4.2,
  "ratingCount": 1240,
  "ratingDistribution": {
    "5": 650,
    "4": 350,
    "3": 150,
    "2": 75,
    "1": 15
  }
}
```

**Capacity:** On-demand

---

## EventBridge Event Bus

**Name:** `platform-events`

All services publish and consume events through this central bus.

### Event Types

#### Domain: `member`

- `member.subscription.created` → Triggers welcome email
- `member.subscription.cancelled` → Triggers churn emails
- `member.profile.updated` → Updates search indices

#### Domain: `review`

- `review.submitted` → Triggers rating aggregation
- `review.updated` → Recalculates aggregates
- `review.deleted` → Decrements counts

#### Domain: `product`

- `product.rating.updated` → Notifies search/recommendations
- `product.added` → Indexes in Elasticsearch

### Example Event

```json
{
  "source": "review-submission",
  "detail-type": "review.submitted",
  "detail": {
    "reviewId": "uuid",
    "productId": "uuid",
    "memberId": "uuid",
    "rating": 4,
    "timestamp": "2026-04-01T10:30:00Z"
  }
}
```

---

## S3 Data Lake

**Bucket:** `platform-datalake-{environment}`

Purpose: Archive of all events, reviews, and analytics snapshots.

```
s3://platform-datalake-prod/
├── events/
│   ├── 2026-04/
│   │   ├── 01/
│   │   │   ├── member/
│   │   │   ├── review/
│   │   │   └── product/
├── analytics/
│   ├── product-ratings/
│   │   ├── 2026-04-01.parquet
│   │   └── 2026-04-02.parquet
```

Used for:

- Data warehousing (Athena queries)
- ML training data
- Historical analysis
- Compliance/audit

---

## Deployment Order

Data platform must be deployed **first**, before any service:

```bash
cd platforms/data-platform
terraform init
terraform apply -var-file=prod.tfvars
```

This creates:

1. DynamoDB tables
2. EventBridge event bus
3. S3 buckets
4. IAM policies for services to access tables

Other platforms depend on these outputs.

---

## Cost Optimization

**Development:** Use on-demand billing

```hcl
billing_mode = "PAY_PER_REQUEST"
```

**Production:** Provisioned capacity (more cost-effective at scale)

```hcl
billing_mode              = "PROVISIONED"
read_capacity_units       = 100
write_capacity_units      = 100
ttl_attribute             = "expiresAt"  # auto-cleanup
point_in_time_recovery    = true
```

**EventBridge:** No cost per event (included in AWS)

**S3:** Lifecycle policies move old data to Glacier after 90 days
