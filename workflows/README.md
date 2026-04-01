# Workflows & Runbooks

This directory contains deployment automation, incident response procedures, and operational runbooks.

---

## GitHub Actions Workflows (`.github/workflows/`)

Automated CI/CD pipelines triggered on pull requests, merges, and manual dispatch.

| Workflow                                                   | Trigger              | Purpose                                             |
| ---------------------------------------------------------- | -------------------- | --------------------------------------------------- |
| [test.yml](.github/workflows/test.yml)                     | PR, push to main     | Run tests, linting, security scans                  |
| [deploy-dev.yml](.github/workflows/deploy-dev.yml)         | Auto (on main merge) | Deploy to dev environment                           |
| [deploy-staging.yml](.github/workflows/deploy-staging.yml) | Manual dispatch      | Deploy to staging with approval                     |
| [deploy-prod.yml](.github/workflows/deploy-prod.yml)       | Manual dispatch      | Deploy to production with multi-stage safety checks |

---

## Runbooks (`workflows/runbooks/`)

Step-by-step procedures for operational tasks and incident response.

### Critical Path

1. **[Incident Response](./runbooks/incident-response.md)** — START HERE for any outage
   - Detection criteria
   - Severity assessment
   - Diagnostics commands
   - Escalation path

2. **[Prod Rollback](./runbooks/prod-rollback.md)** — Revert a bad deployment
   - When to rollback
   - Rollback procedure
   - Verification steps
   - Post-incident actions

### Operational

3. **[Data Correction](./runbooks/data-correction.md)** — Fix data inconsistencies
   - Backup procedures
   - Batch corrections
   - Verification
   - Audit trails

---

## Approval Gates & Deployment Stages

See [APPROVAL-GATES.md](./APPROVAL-GATES.md) for:

- PR review criteria
- Dev → Staging → Prod progression
- Required approvals at each stage
- Rollback triggers

---

## Quick Start

### Deploy to Staging

```bash
# Trigger workflow via GitHub UI
# Or: gh workflow run deploy-staging.yml
# Wait for plan, review changes, approve
```

### Handle Production Incident

1. Open incident ticket
2. Run [Incident Response](./runbooks/incident-response.md)
3. If needed, run [Prod Rollback](./runbooks/prod-rollback.md)

### Fix Data

1. Run [Data Correction](./runbooks/data-correction.md)
2. Create backup
3. Apply fix
4. Verify

---

## Workflow Status

Check deployment history:

```bash
gh workflow list
gh run list --workflow=deploy-prod.yml
gh run view <run-id> --exit-status
```

---

## Environment Details

| Env     | AWS Region                 | Auto Deploy  | Approval Required    |
| ------- | -------------------------- | ------------ | -------------------- |
| dev     | eu-west-1                  | ✅ (on main) | ❌                   |
| staging | eu-west-1                  | ❌           | ✅ (Platform Lead)   |
| prod    | eu-west-1 + us-east-1 (DR) | ❌           | ✅✅ (Lead + VP Eng) |

---

## Secrets Required

Store in GitHub Secrets:

- `AWS_ROLE_TO_ASSUME_DEV`
- `AWS_ROLE_TO_ASSUME_STAGING`
- `AWS_ROLE_TO_ASSUME_PROD`
- `TERRAFORM_STATE_BUCKET`
- `SLACK_WEBHOOK_URL`
- `SLACK_WEBHOOK_PROD` (for critical alerts)

---

## Related

- [Deployment Guide](../docs/DEPLOYMENT.md)
- [AWS Rules](./../.claude/rules/aws.md)
- [Testing Standards](./../.claude/rules/testing.md)
