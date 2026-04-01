# Production Rollback Runbook

**Severity:** CRITICAL  
**Response Time:** < 5 minutes  
**Owner:** Platform Team Lead

---

## When to Rollback

Initiate rollback if:

- Error rate > 5% (check CloudWatch)
- API p99 latency > 2 seconds
- Database connection errors
- Data corruption detected
- DynamoDB throttling
- Revenue-impacting features down

**Do NOT rollback if:** Issue affects only non-critical or internal services.

---

## Step 1: Assess Severity

```bash
# Check current error rates
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Errors \
  --start-time $(date -u -d '10 minutes ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 60 \
  --statistics Sum,Average

# Check API Gateway
aws apigatewayv2 get-stage \
  --api-id $API_ID \
  --stage-name prod
```

**Decision:** Is error rate > 5%? → Continue with rollback

---

## Step 2: Notify Stakeholders

```bash
# Slack message to #incidents
# Message: "Production Incident - Initiating Rollback"
# Include: error rate, affected service, ETA
```

**Notify:**

- Platform Lead
- On-call Engineer
- Service Owners
- #incidents Slack channel

---

## Step 3: Identify Previous Good State

```bash
# Get the previous release tag
git describe --tags --abbrev=0
# Example: release-abc123def456

# Show what changed
git log --oneline abc123..HEAD

# Check Terraform state history
cd platforms/infrastructure
terraform state list
terraform show
```

**Review:** What changed in the failing deployment?

---

## Step 4: Revert Terraform

### Option A: Automated Script

```bash
# Run the rollback script (pre-tested)
./scripts/rollback-prod.sh
```

### Option B: Manual Rollback

```bash
cd platforms/infrastructure
terraform init \
  -backend-config="bucket=$TF_STATE_BUCKET" \
  -backend-config="key=infrastructure/prod"

# Get previous state
terraform state pull > current.tfstate
git show HEAD~1:.terraform/state > previous.tfstate

# Rollback
terraform state push previous.tfstate

# Verify
terraform plan -var-file=prod.tfvars
# This should show resources being destroyed and recreated from previous state

terraform apply -auto-approve
```

### Option C: Quick Hotfix (if rollback is risky)

If rolling back the entire deployment is risky:

```bash
# Instead, deploy a targeted fix
cd platforms/infrastructure/lambdas/[failing-service]/
git revert HEAD
npm run build
terraform apply -target aws_lambda_function.handler
```

---

## Step 5: Verify Rollback

```bash
# Function 1: Check Lambda is running
aws lambda invoke \
  --function-name $FUNCTION_NAME-prod \
  --payload '{"test": true}' \
  /tmp/response.json
cat /tmp/response.json

# Function 2: Check API health
curl -H "Authorization: Bearer $TOKEN" https://api.example.com/health

# Function 3: Check CloudWatch errors have dropped
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Errors \
  --start-time $(date -u -d '5 minutes ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 60 \
  --statistics Sum
```

**Expected:** Error rate < 1%, latency < 500ms

---

## Step 6: Post-Incident

### Immediate (< 30 min)

- [ ] Post-mortem Slack message
- [ ] Assign incident ticket
- [ ] Notify stakeholders rollback complete

### Within 24 hours

- [ ] Root cause analysis
- [ ] Code review: why did tests miss this?
- [ ] Add regression test
- [ ] Update runbook if needed

### Within 1 week

- [ ] Full RCA document
- [ ] Team sync on findings
- [ ] Deploy fix to staging, verify, then to prod

---

## Rollback Checklist

- [ ] Error rate confirmed > 5%
- [ ] Stakeholders notified
- [ ] Previous good state identified
- [ ] Terraform rollback executed
- [ ] Health checks passing
- [ ] RCA ticket created
- [ ] Team aware of issue

---

## Related Docs

- [Incident Response](./incident-response.md)
- [Prod Deployment Flow](./../deploy-prod.yml)
- [DynamoDB Troubleshooting](./dynamodb-troubleshooting.md)
