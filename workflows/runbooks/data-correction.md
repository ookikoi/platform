# Data Correction Runbook

**Use Case:** A review was submitted with incorrect data (e.g., user marked their own review as helpful 100x, or rating aggregate is out of sync)

**Severity:** Medium (impacts search ranking, not revenue-blocking)

---

## Before You Start

- [ ] Has this issue been verified? (Check the data in DynamoDB)
- [ ] How many records are affected? (1 review or 10,000?)
- [ ] Can it be automated or is it a one-off?

---

## Step 1: Identify Affected Data

```bash
# Example: Find reviews with impossible "helpful" count

aws dynamodb scan \
  --table-name reviews-prod \
  --filter-expression "helpful > #limit" \
  --expression-attribute-values '{":limit":{"N":"1000"}}'

# Save to file
aws dynamodb scan \
  --table-name reviews-prod \
  --filter-expression "helpful > :limit" \
  --expression-attribute-values '{":limit":{"N":"1000"}}' \
  > /tmp/affected-reviews.json

# Count affected
cat /tmp/affected-reviews.json | jq '.Items | length'
```

---

## Step 2: Assess Impact on Platforms

**Q: Will this data correction break anything?**

- [ ] Does it affect search ranking? (Check Elasticsearch index)
- [ ] Does it affect recommendations? (Check SageMaker model input)
- [ ] Does it affect billing? (Check transaction table)

**If yes to any:** Escalate to service owners before proceeding.

---

## Step 3: Create Backup

```bash
# Export the current state (in case we need to rollback)
aws dynamodb scan \
  --table-name reviews-prod \
  --filter-expression "helpful > :limit" \
  --expression-attribute-values '{":limit":{"N":"1000"}}' \
  > /tmp/backup-before-correction.json

# Upload to S3 for audit trail
aws s3 cp /tmp/backup-before-correction.json \
  s3://platform-datalake-prod/corrections/$(date +%Y-%m-%d)/reviews-backup.json

echo "Backup saved to S3"
```

---

## Step 4: Perform Correction

### Option A: Batch Update (Lambda)

Create a one-off Lambda to fix records:

```typescript
import { DynamoDBClient, UpdateItemCommand } from "@aws-sdk/client-dynamodb";

const client = new DynamoDBClient({ region: "eu-west-1" });

const affectedReviewIds = [
  "review-001",
  "review-002",
  // ... from affected-reviews.json
];

for (const reviewId of affectedReviewIds) {
  await client.send(
    new UpdateItemCommand({
      TableName: "reviews-prod",
      Key: { reviewId: { S: reviewId } },
      UpdateExpression: "SET helpful = :zero",
      ExpressionAttributeValues: {
        ":zero": { N: "0" },
      },
    }),
  );
  console.log(`Fixed ${reviewId}`);
}

console.log("Correction complete");
```

Run it:

```bash
cd /tmp/corrections
npm init -y
npm install @aws-sdk/client-dynamodb
node fix.js
```

### Option B: Direct CLI (One or Two Records)

```bash
# Single record
aws dynamodb update-item \
  --table-name reviews-prod \
  --key '{"reviewId":{"S":"review-abc123"}}' \
  --update-expression "SET helpful = :zero" \
  --expression-attribute-values '{":zero":{"N":"0"}}'

# Multiple records
for review_id in review-001 review-002; do
  aws dynamodb update-item \
    --table-name reviews-prod \
    --key "{\"reviewId\":{\"S\":\"$review_id\"}}" \
    --update-expression "SET helpful = :zero" \
    --expression-attribute-values '{":zero":{"N":"0"}}'
  echo "Fixed $review_id"
done
```

### Option C: Terraform Data Import

If the issue is in your infrastructure state itself, reimport:

```bash
cd platforms/infrastructure
terraform refresh
# Check if state is now correct
terraform plan
```

---

## Step 5: Verify Correction

```bash
# Check if the fix worked
aws dynamodb get-item \
  --table-name reviews-prod \
  --key '{"reviewId":{"S":"review-abc123"}}'

# Should show: "helpful": {"N": "0"}

# If bulk: check a sample
aws dynamodb query \
  --table-name reviews-prod \
  --key-condition-expression "productId = :pid" \
  --expression-attribute-values '{":pid":{"S":"product-xyz"}}' \
  | jq '.Items[] | {reviewId, helpful, rating}'
```

---

## Step 6: Update Rating Aggregates

If you corrected individual reviews, re-run the aggregation:

```bash
# Invoke the rating-aggregate-event Lambda manually
aws lambda invoke \
  --function-name rating-aggregate-event-prod \
  --payload '{
    "source": "manual-correction",
    "productIds": ["product-001", "product-002"]
  }' \
  /tmp/response.json

cat /tmp/response.json
```

Or wait for the scheduled aggregator (1-hour cron).

---

## Step 7: Auditing

Record what you did:

```bash
# Create audit log
cat > /tmp/audit.json <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "correctedTable": "reviews-prod",
  "recordsAffected": 5,
  "issue": "Helpful count was impossible (> 1000)",
  "action": "Set helpful = 0",
  "approvedBy": "platform-lead",
  "backupLocation": "s3://platform-datalake-prod/corrections/2026-04-01/reviews-backup.json",
  "verifiedCorrect": true
}
EOF

aws s3 cp /tmp/audit.json \
  s3://platform-datalake-prod/corrections/$(date +%Y-%m-%d)/audit.json
```

---

## Step 8: Notify Services

**If you modified data that affects:**

- **Search:** Re-index Elasticsearch
- **Recommendations:** Retrain model
- **Revenue:** Notify Finance

```bash
# Emit event to notify services
aws events put-events \
  --entries '[{
    "Source": "data-correction",
    "DetailType": "reviews.corrected",
    "Detail": "{\"productIds\": [\"product-001\"], \"reason\": \"helpful_count_reset\"}"
  }]' \
  --event-bus-name platform-events
```

---

## Rollback (Uh-Oh)

If the correction was wrong:

```bash
# Restore from backup
aws s3 cp \
  s3://platform-datalake-prod/corrections/2026-04-01/reviews-backup.json \
  /tmp/backup.json

# Restore each item
# (Re-run the backup against DynamoDB or use AWS DMS)
```

---

## Checklist

- [ ] Issue verified in DynamoDB
- [ ] Backup created and stored
- [ ] Correction executed
- [ ] Verification passed
- [ ] Audit log created
- [ ] Dependent services notified
- [ ] Team aware

---

## Common Issues

**Q: "The query is too slow"**  
A: Use `--consistent-read` flag, or filter in application code instead of DynamoDB

**Q: "I updated 1000 items but not all changed"**  
A: DynamoDB batch limits. Use parallel processes or Lambda invocations

**Q: "The correction was wrong!"**  
A: Restore from backup in S3, document as lesson-learned

---

## Related

- [Incident Response](./incident-response.md)
- [Terraform State Management](../../docs/DEPLOYMENT.md)
