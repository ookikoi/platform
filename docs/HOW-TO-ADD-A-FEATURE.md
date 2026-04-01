# How to Add a Feature

Step-by-step guide for adding a new feature to the platform.

---

## Choose Your Path

You have **two ways** to create a feature:

### **Path A: Interactive Wizard (Recommended for new devs)**

```bash
/feature
```

Guided experience with questions:

- "What are you building?"
- "Is this cross-platform?"
- "What services do you need?"
- Creates PRD + scaffolding automatically
- Get implementation checklist

**Use this if:** You're unsure about scope, structure, or what to build  
**Time:** ~5 min to get fully scaffolded and ready to code

**See:** [.claude/commands/feature.md](../.claude/commands/feature.md)

---

### **Path B: Granular Commands (For experienced devs)**

```bash
/lambda search-api --trigger api
/event product.indexed
/component SearchResults
```

Full control—create each piece separately:

- Build exactly what you need
- Understand each part as you go
- Combine granular commands in any order

**Use this if:** You know exactly what you need or learning the architecture  
**Time:** ~10 min (same work as wizard, more steps visible)

**See:**

- [.claude/commands/lambda.md](../.claude/commands/lambda.md) — Create Lambda
- [.claude/commands/event.md](../.claude/commands/event.md) — Define event
- [.claude/commands/component.md](../.claude/commands/component.md) — Create React component

---

## The Manual 9-Step Process (If you skip commands)

If you prefer not to use commands, follow these steps:

---

## Overview

**Feature = anything new users can do**

Examples:

- Add product search
- Allow members to filter reviews
- Send email notifications
- Aggregate product ratings

**Required for all features:**

1. PRD (product requirements document)
2. Implementation (Lambda, Terraform, tests)
3. Deployment (dev → staging → prod)

---

## Step 1: Do You Need a PRD?

### **PRD Required** (cross-platform features)

Your feature touches multiple services:

- [ ] Creates a new event (EventBridge)
- [ ] Adds a shared table (DynamoDB)
- [ ] Changes an existing API contract
- [ ] Affects the system architecture
- [ ] Impacts 2+ platform domains

**Example:** "Add member search"

- Needs: search-api Lambda, Elasticsearch integration, search.performed event
- Affects: Search domain, Data platform, Potentially recommendations

### **PRD Optional** (isolated changes)

Changes are contained to one service:

- [ ] Bug fix in existing Lambda
- [ ] New component in design system
- [ ] Optimization (no behavior change)
- [ ] Documentation

**Example:** "Fix typo in dashboard"

- Affects: Only dashboard component
- No events, no new services, no schema changes

---

## Step 2: Write the PRD

### **When**

Before writing any code. PRD is your roadmap.

### **Where**

Create file: `PRDs/[feature-name]-YYYY-MM-DD.md`

**Example:** `PRDs/member-search-2026-04-01.md`

### **What Goes In It**

Use this template:

```markdown
# Feature: Member Search

**Status:** Approved  
**Date:** 2026-04-01  
**Owner:** @your-name  
**Stakeholders:** Product, Search Team

---

## Overview

Members can search for products by name, category, and price.

---

## User Journey

User → Search bar → See results → Click product → Read reviews

---

## Services Required

| Service                 | Purpose                                   |
| ----------------------- | ----------------------------------------- |
| search-api              | HTTP endpoint for search                  |
| search-indexer-event    | Update Elasticsearch when products change |
| SearchResults component | Display results UI                        |

---

## Success Criteria

- [ ] Search returns results in < 200ms
- [ ] Supports filters: name, category, price range
- [ ] Results ranked by rating
- [ ] Mobile-responsive UI
- [ ] Analytics: log search queries

---

## Dependencies

- Elasticsearch domain (new infra)
- Product table has category field (exists)
- Rating aggregates up to date (event-driven)

---

## Platform Impact

- New event: `product.indexed`
- New Lambda: search-api
- New Elasticsearch index: products

---

## Rollout Plan

1. Deploy to dev (2 days)
2. QA in staging (3 days)
3. Canary: 10% prod traffic (1 day)
4. Full rollout

---

## Success Metrics

- 95% of searches return results
- Avg search time: 150ms
- 0 errors in first week
```

### **Get Approval**

- Product owner: reviews requirements
- Tech lead: reviews feasibility
- Both approve → proceed

---

## Step 3: Break Down Into Services

Your PRD says what needs to exist. Now decide **which Lambdas/components to create**.

**Example: Member Search**

PRD says → Search results visible, filtered by category, fast

**Services needed:**

1. `search-api` — HTTP endpoint
2. `search-indexer-event` — Index products when they change
3. `SearchResults` component — UI for displaying results

---

## Step 4: Create Each Service

For **each Lambda**, run:

```bash
/lambda search-api --trigger api

# This creates:
# platforms/infrastructure/lambdas/search-api/
# ├── src/handler.ts
# ├── src/handler.test.ts
# ├── src/types.ts
# └── infra/main.tf
```

For **each Event**, run:

```bash
/event product.indexed

# This creates:
# platforms/data-platform/events/product.indexed/
# ├── schema.ts
# ├── publisher.ts
# └── consumer.ts
```

For **each Component**, run:

```bash
/component SearchResults

# This creates:
# platforms/design-system/components/SearchResults/
# ├── SearchResults.tsx
# ├── SearchResults.test.tsx
# └── SearchResults.stories.tsx
```

---

## Step 5: Implement

**Write code in this order:**

### 1. Data Model (Zod schema)

```typescript
// src/types.ts
const SearchQuerySchema = z.object({
  query: z.string().min(1),
  category: z.string().optional(),
  priceMax: z.number().optional(),
});
```

### 2. Tests (TDD)

```typescript
// src/handler.test.ts
it("returns products matching query", async () => {
  const result = await handler({
    queryStringParameters: { query: "coffee" },
  });
  expect(result.statusCode).toBe(200);
  expect(JSON.parse(result.body).results.length).toBeGreaterThan(0);
});
```

### 3. Handler Logic

```typescript
// src/handler.ts
export const handler = async (event) => {
  const query = SearchQuerySchema.parse(event.queryStringParameters);
  const results = await searchElasticsearch(query);
  return { statusCode: 200, body: JSON.stringify(results) };
};
```

### 4. Infrastructure (Terraform)

```hcl
# infra/main.tf
resource "aws_lambda_function" "handler" {
  # ... Lambda config
}

resource "aws_apigatewayv2_integration" "search" {
  target_uri = aws_lambda_function.handler.invoke_arn
}
```

### 5. Tests Pass Locally

```bash
npm test
npm run build
terraform validate
```

---

## Step 6: Update Architecture Diagram

Your feature is complete, but nobody knows about it. Update the system map so future devs understand:

```bash
# Run the diagram command to regenerate
/diagram update

# Or manually edit: architecture/system-map.md
# Add your new service to the diagram
```

---

## Step 7: Create Pull Request

```bash
git checkout -b feature/member-search
git add .
git commit -m "Add member search capability (Closes PRD-XXX)"
git push origin feature/member-search
```

**Open PR on GitHub.**

**Checklist in PR description:**

- [ ] PRD linked (Closes PRD-XXX)
- [ ] All tests pass
- [ ] No hardcoded secrets
- [ ] Terraform validates
- [ ] Design system tokens used
- [ ] Architecture diagram updated
- [ ] Ready for dev deployment

---

## Step 8: Code Review

Engineers review your code:

- ✅ Code quality
- ✅ Test coverage (90% for Lambda)
- ✅ Security (no SQL injection, proper IAM)
- ✅ Following platform rules

**Get 2 approvals → merge to main**

---

## Step 9: Deployment

### **Dev (automatic)**

```
Merge to main → GitHub Actions runs → Auto-deploy to dev
```

Test in dev environment using AWS console.

### **Staging (manual)**

```
# When ready
gh workflow run deploy-staging.yml

# Wait for approval
# Staging environment is live
```

### **Production (manual, with safety checks)**

```
# When product says go
gh workflow run deploy-prod.yml

# Multiple approvals required
# Smoke tests run automatically
# Metrics verified
# Production live 🚀
```

See: [workflows/APPROVAL-GATES.md](../workflows/APPROVAL-GATES.md)

---

## Troubleshooting

### "Tests failing"

Check `npm test` output. Fix code. Re-test.

### "Terraform invalid"

Run `terraform validate` to see syntax errors. Fix and retry.

### "PR blocked without PRD"

You said this was cross-platform but didn't link a PRD. Either:

- Create the PRD (go back to Step 2)
- Or change scope to make it single-service

### "Deploy to staging stuck"

See: [workflows/APPROVAL-GATES.md](../workflows/APPROVAL-GATES.md#gate-4-staging-deployment-manual)

---

## Checklist: Feature Complete

- [ ] PRD created and approved
- [ ] All services scaffolded (`/lambda`, `/event`, `/component`)
- [ ] Code written + all tests pass
- [ ] Tests > 90% coverage (Lambda) / 80% (Components)
- [ ] Terraform validates
- [ ] No hardcoded secrets
- [ ] PR created with PRD link
- [ ] PR approved (2 approvals)
- [ ] Merged to main
- [ ] Auto-deployed to dev
- [ ] Tested in dev
- [ ] Architecture diagram updated
- [ ] Promoted to staging
- [ ] Promoted to production
- [ ] Success metrics tracked

---

## Related Docs

- [GETTING-STARTED.md](./GETTING-STARTED.md) — Onboarding
- [ARCHITECTURE.md](./ARCHITECTURE.md) — System design
- [DEPLOYMENT.md](./DEPLOYMENT.md) — Deployment process
- [.claude/rules/](../.claude/rules/) — Platform rules
- [workflows/APPROVAL-GATES.md](../workflows/APPROVAL-GATES.md) — Approval process
