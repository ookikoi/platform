# Incident Response Runbook

**Escalation Path:** On-call → Platform Lead → VP Engineering → CTO

---

## Detection

### Automated Alerts (CloudWatch)

| Alert                 | Threshold            | Action       |
| --------------------- | -------------------- | ------------ |
| Lambda Error Rate     | > 5% for 5 min       | Page on-call |
| API p99 Latency       | > 2 sec for 5 min    | Page on-call |
| DynamoDB Throttling   | any throttle         | Page on-call |
| Member Dashboard Down | 0 requests for 2 min | Page on-call |

### Manual Detection

Users report in Slack:

- "I can't sign up"
- "Reviews won't load"
- "Dashboard is slow"

**Action:** Run diagnostics immediately

---

## Step 1: Assess Impact (2 min)

```bash
# 1. Check affected service
aws logs tail /aws/lambda/[service]-prod --follow --max-items=50

# 2. Check error type
# - 4xx? Input validation issue or auth failure
# - 5xx? Service / database issue
# - Timeout? Downstream (DynamoDB, external API) is slow

# 3. Check scope
# - Single user? Likely auth/permission issue
# - All users? Platform-wide incident
# - Specific feature? Service-specific issue
```

**Output Decision Matrix:**

| Error         | Scope          | Severity | Next Action              |
| ------------- | -------------- | -------- | ------------------------ |
| 403 Forbidden | Single user    | Low      | Check IAM/Cognito groups |
| 500 Internal  | Platform-wide  | CRITICAL | → Incident Protocol      |
| Timeout       | Single feature | Medium   | → Diagnostics            |

---

## Step 2: Incident Protocol (5 min)

1. **Open incident ticket**

   ```
   Title: [CRITICAL] Member Dashboard Down
   Severity: P1
   Service: review-submission, member-profile
   Status: INVESTIGATING
   ```

2. **Post to #incidents**

   ```
   🚨 INCIDENT: Member Dashboard Down
   Severity: P1
   Status: INVESTIGATING
   ETA: TBD
   Leads: @platform-lead
   ```

3. **Try Quick Fixes** (3 min window)
   - Restart Lambda? `aws lambda update-function-configuration --function-name X`
   - DynamoDB throttling? Increase capacity temporarily
   - External API down? Switch to fallback

4. **If not resolved in 3 min → Escalate**
   - Prepare rollback (get previous commit SHA)
   - Page VP Engineering
   - Start post-mortem doc

---

## Step 3: Diagnostics

### Lambda Diagnostics

```bash
# Check cold starts
aws logs filter-log-events \
  --log-group-name /aws/lambda/$FUNCTION \
  --filter-pattern "REPORT" \
  --start-time $(date -d '10 minutes ago' +%s)000

# Check DLQ
aws sqs receive-message \
  --queue-url $DLQ_URL \
  --max-number-of-messages 10
```

### DynamoDB Diagnostics

```bash
# Check consumed capacity
aws dynamodb describe-table --table-name $TABLE | jq .Table.ProvisionedThroughput

# Check hot partitions
aws cloudwatch get-metric-statistics \
  --namespace AWS/DynamoDB \
  --metric-name ConsumedWriteCapacityUnits \
  --dimensions Name=TableName,Value=$TABLE \
  --statistics Sum \
  --period 60 \
  --start-time $(date -u -d '20 minutes ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S)

# Check throttled requests
aws dynamodb describe-table --table-name $TABLE | jq .Table.TableStatus
```

### Dependency Check

```bash
# Is Cognito up?
aws cognito-idp describe-user-pool --user-pool-id $POOL_ID

# Is EventBridge flowing?
aws events list-rules | grep platform-events
```

---

## Step 4: Root Cause

| Symptom                      | Root Cause                      | Fix                             |
| ---------------------------- | ------------------------------- | ------------------------------- |
| High error rate after deploy | Bad code in latest Lambda       | Rollback (see prod-rollback.md) |
| DynamoDB throttling          | Hot partition on PK             | Increase WCU or use on-demand   |
| Cognito 403                  | IAM policy missing              | Add permission to role          |
| Timeout on review-submit     | EventBridge rule not forwarding | Check rule targets              |
| Memory exceeded              | Code leak (unbounded array)     | Deploy hotfix lambda            |

---

## Step 5: Mitigation

**Immediate (stop the bleeding):**

- Rollback if bad deploy
- Increase DynamoDB capacity
- Disable non-critical features (feature flag)
- Route traffic to healthy region (if DR setup)

**Short-term (restore service):**

- Deploy hotfix
- Monitor for 30 min
- Declare incident resolved

**Long-term (prevent recurrence):**

- RCA document
- Add test case
- Update runbook

---

## Step 6: Post-Incident

**While on-call:**

1. Timeline of events
2. What failed?
3. What alert missed it?
4. Duration of outage

**Within 24 hours:** 5. Root cause 6. Permanent fix

**Within 1 week:** 7. Post-mortem meeting 8. Assigned owners for preventions

---

## Communication Template

### Initial (5 min)

```
🚨 INCIDENT: [SERVICE] Down
Severity: P1 | Status: INVESTIGATING
Lead: @xxx | ETA: TBD
```

### Update (10 min)

```
📊 UPDATE:
Root cause: [Identified]
Impact: [X users affected, Y% of traffic]
Next step: [Rollback | Hotfix | Scale]
ETA: [time]
```

### Resolution (all good)

```
✅ RESOLVED:
Outage duration: X min
Impact: Y users
Root cause: Z
RCA ticket: #123
```

---

## When to Declare "Resolved"

- [ ] Error rate < 1%
- [ ] All health checks passing
- [ ] No new errors in DLQ
- [ ] User reports stopped
- [ ] Dashboard metrics normal

---

## Related

- [Prod Rollback](./prod-rollback.md)
- [DynamoDB Troubleshooting](./dynamodb-troubleshooting.md)
- [CloudWatch Dashboards](https://console.aws.amazon.com/cloudwatch/)
