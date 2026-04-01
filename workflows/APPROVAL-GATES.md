# Approval Gates & Deployment Stages

This document defines the gates and reviews required before code reaches production.

---

## Overview

```
Feature Branch
    ↓
PR → Code Review → Tests Pass → Merge to main
    ↓
main → Deploy to dev (automatic)
    ↓
Staging (manual approval) → Smoke tests
    ↓
Production (manual + staged rollout)
```

---

## Gate 1: Pull Request (Code Review)

**Who:** Any 2 of platform-team  
**Checklist:**

- [ ] Tests pass (90% Lambda, 80% Components)
- [ ] No hardcoded secrets / credentials
- [ ] Follows naming conventions (.claude/rules/)
- [ ] Does this touch cross-platform contracts? (If yes, PRD required)
- [ ] Terraform plan is clean (no breaking changes)

**Rules for Approval:**

- If touching `platforms/infrastructure/` → requires infrastructure review
- If touching `platforms/design-system/` → requires design review
- If touching `.claude/rules/` → requires platform lead approval

**Blocking conditions:**

- ❌ Tests failing
- ❌ Secrets in code
- ❌ Breaking changes without migration plan
- ❌ No test coverage increase

---

## Gate 2: Merge to Main

**Requirement:** 2 approvals + all checks green

**Action:** Automatically triggers `deploy-dev.yml` workflow

---

## Gate 3: Dev Deployment (Automatic)

Runs on every merge to main.

**Workflow:** `.github/workflows/deploy-dev.yml`

**If fails:** Slack notification, PR author alerted

---

## Gate 4: Staging Deployment (Manual)

**Trigger:** Workflow dispatch or tag push

**Requirements:**

- [ ] Run in non-prod environment first
- [ ] Smoke tests must pass
- [ ] Performance benchmarks reviewed
- [ ] Data migrations tested

**Approval:** Platform Lead

**Workflow:** `.github/workflows/deploy-staging.yml`

**Duration:** ~10 min including tests

---

## Gate 5: Production Deployment (Manual + Staged)

**Trigger:** Workflow dispatch (human decision)

**Pre-checks:**

- [ ] Commit is in main (verified by workflow)
- [ ] Commit was deployed to staging successfully
- [ ] No critical alerts in prod
- [ ] Runbooks reviewed
- [ ] Rollback plan ready

**Approvals needed:**

1. Platform Lead
2. VP Engineering (or on-call for `>= P1` fixes)

**Workflow:** `.github/workflows/deploy-prod.yml`

**Deployment stages:**

1. Deploy infrastructure (1 min)
2. Deploy services (2 min)
3. Run smoke tests (3 min)
4. Verify metrics (2 min)
5. If all green → production live

**If anything fails:** Auto-rollback to previous release

**Expected duration:** 15-20 minutes total

---

## Special Cases

### Hotfix to Production

If there's a critical bug in prod (P1/P2), you can skip staging:

1. Create branch from main: `hotfix/member-auth-broken`
2. Fix the issue + add regression test
3. PR with label `hotfix`
4. Requires lead approval
5. Deploy directly to prod (skip staging)
6. Include revert plan in PR description

**Post-hotfix:** Still need to go through normal staging for next release

---

### Rollback

If production is broken:

1. Open incident ticket
2. RUN: [Prod Rollback Runbook](./runbooks/prod-rollback.md)
3. Approval: Platform Lead only (no VP Engineering needed, immediate)
4. Deploy previous release tag

See `workflows/runbooks/prod-rollback.md` for full procedure.

---

### Feature Flags (Release Without Deploy)

To deploy code but not run it:

```typescript
// In handler.ts
if (process.env.FEATURE_FLAG_REVIEWS_V2 === "true") {
  // New code path
} else {
  // Old code path
}
```

Deploy code with flag OFF, then flip in AWS Systems Manager:

```bash
aws ssm put-parameter \
  --name /company/prod/feature-flags/reviews-v2 \
  --value "true" \
  --overwrite
```

No re-deploy needed, instant activation.

---

## Checklist Before Requesting Production

- [ ] PR approved by 2 engineers
- [ ] All tests green
- [ ] Staging deployment successful
- [ ] Smoke tests passed
- [ ] Runbooks reviewed
- [ ] Rollback plan documented
- [ ] Team aware of deployment

---

## Monitoring After Deploy

**First 5 minutes:**

- Error rate < 1%
- Latency < 500ms
- No DLQ messages

**First 30 minutes:**

- Dashboard loading correctly
- Reviews can be submitted
- Ratings aggregating
- Search working

**First 2 hours:**

- Revenue metrics normal
- No customer escalations
- CloudWatch dashboards steady

---

## Rollback Criteria

Automatically rollback if:

- Error rate > 5%
- p99 latency > 2 seconds
- Any Lambda timeout
- DynamoDB throttling

Manual rollback if:

- Data corruption detected
- Auth broken for users
- Search indices corrupted

See: [Prod Rollback Runbook](./runbooks/prod-rollback.md)

---

## Related Docs

- [Incident Response](./runbooks/incident-response.md)
- [Prod Rollback](./runbooks/prod-rollback.md)
- [Testing Standards](./../.claude/rules/testing.md)
