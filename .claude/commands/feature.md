# Command: /feature

Feature creation wizard with optional arguments. Use fully interactive mode or provide arguments for faster scaffolding.

---

## Usage

### Interactive Mode (Recommended for learning)

```
/feature
```

Fully interactive. The wizard asks you questions and guides you through each step.

### Argument Mode (Fast, for experienced devs)

```
/feature --name product-search --services lambda event component --prd
```

Provide arguments to skip questions and scaffold instantly.

### Hybrid Mode (Mix and match)

```
/feature --name product-search
# → Skips "what are you building?" but asks about services, PRD, etc.
```

### Parameters

| Parameter         | Optional | Example                              |
| ----------------- | -------- | ------------------------------------ |
| `--name`          | Yes      | `--name product-search`              |
| `--services`      | Yes      | `--services lambda event component`  |
| `--prd`           | Yes      | Include flag to create PRD           |
| `--skip-scaffold` | Yes      | Create PRD only, no code scaffolding |

---

## Examples

### Fully Interactive (Learning Mode)

```bash
/feature

? What are you building?
> Add product search by name and category

? Is this cross-platform?
> Yes, needs multiple services

? Which services?
> [✓] Lambda (search-api)
> [✓] Event (product.indexed)
> [✓] Component (SearchResults)

? Create PRD file?
> Yes

? Scaffold all services now?
> Yes

→ Creates PRD + all scaffolding + checklist
```

### Fast Mode with Arguments

```bash
/feature --name product-search --services lambda event component --prd

? Confirm for product-search:
  - scaffold-api Lambda (HTTP API)
  - product.indexed Event
  - SearchResults Component
  - Create PRD?
> YES

→ All created, ready to code
```

### PRD Only (No Scaffolding)

```bash
/feature --name product-search --prd --skip-scaffold

→ Creates PRDs/product-search-2026-04-01.md only
→ You scaffold services manually with /lambda, /event, /component
```

### Just a Component (No PRD)

```bash
/feature --name rating-display --services component

→ Creates SearchResults component only
→ No PRD (isolated change, single service)
```

---

## When to Use Each Approach

| Mode            | When                       | Command                                   |
| --------------- | -------------------------- | ----------------------------------------- |
| **Interactive** | Learning, exploring        | `/feature`                                |
| **Arguments**   | I know what I need         | `/feature --name X --services Y Z --prd`  |
| **Hybrid**      | Some known, some uncertain | `/feature --name X`                       |
| **PRD only**    | Don't want to scaffold yet | `/feature --name X --prd --skip-scaffold` |
| **One piece**   | Just one Lambda/component  | `/lambda search-api` (skip wizard)        |

---

## The Feature Creation Journey

### **Path A: Following the Wizard (All at Once)**

```
/feature                    (or with args: /feature --name X --services Y Z --prd)
  ↓ Asks questions (or skips if given args)
  ↓ Determines if PRD needed
  ↓ Creates scaffolding for all services
  ↓ Generates implementation checklist
```

**Pros:** Guided, foolproof, clear next steps  
**Cons:** Less control over individual pieces

### **Path B: Granular Step-by-Step (Maximum Control)**

```
/lambda search-api --trigger api      (create + implement handler)
↓
/event product.indexed                 (define schema + publisher)
↓
/component SearchResults              (build UI + tests)
↓
/diagram                              (update architecture)
↓
Create PR manually
```

**Pros:** Full control, learn what each piece does  
**Cons:** More commands to remember

---

## What the Wizard Does

When you run `/feature`, it will:

1. **Ask about your feature**
   - "What are you building?"
   - "Who requested this?"
   - "Why is it important?"

2. **Assess scope**
   - Single service? Multiple services?
   - Cross-platform? Needs PRD?
   - New events? New tables?

3. **Choose scaffolding approach**
   - Option A: Create PRD + all scaffolding now
   - Option B: Create PRD only, scaffold services individually
   - Option C: Skip PRD (small isolated changes only)

4. **Create PRD** (if cross-platform)

   ```
   PRDs/[feature-name]-YYYY-MM-DD.md
   ```

5. **Scaffold services** (your choice)

   ```
   /lambda search-api
   /event product.indexed
   /component SearchResults
   ```

6. **Generate implementation checklist**
   ```
   [ ] Handler business logic
   [ ] All tests pass (90%)
   [ ] Infrastructure reviewed
   [ ] Architecture diagram updated
   [ ] Ready for code review
   ```

---

## Example Feature Workflow

### Scenario: Add Product Search

```bash
$ /feature

? What are you building?
> Add product search by name and category

? Is this cross-platform (multiple services or new events)?
> Yes, affects search, products, recommendations

? Which services do you need?
> [ ] Lambda (search-api)
> [ ] Event (product.indexed)
> [ ] Component (SearchResults)
> [ ] DynamoDB table
> [ ] Other: ___

? Need a PRD?
> Yes, create it now

---

Created: PRDs/product-search-2026-04-01.md

Would you like to scaffold the services now?
> [ ] Create all at once
> [ ] Do them one by one

Scaffolding search-api Lambda...
Scaffolding product.indexed Event...
Scaffolding SearchResults Component...

---

Implementation Checklist:
[ ] Handler: Validate search query, query DynamoDB
[ ] Handler tests: Happy path, empty results, invalid input
[ ] Event: Define product.indexed schema
[ ] Component: Render results with pagination
[ ] Component tests: Render, click result, accessibility
[ ] Infrastructure: Add DynamoDB index for search
[ ] Architecture: Update system-map.md to show event flow
[ ] Ready for code review

Next: Edit src/handler.ts and write real business logic.
```

---

## When to Use Each Path

| Situation                                      | Use This                   |
| ---------------------------------------------- | -------------------------- |
| "I have an idea but don't know where to start" | `/feature` wizard          |
| "I know exactly what I need (1 Lambda)"        | `/lambda search-api`       |
| "I'm creating an event, need a schema first"   | `/event product.indexed`   |
| "I'm building a UI component"                  | `/component SearchResults` |
| "I'm already in the code, skip scaffolding"    | Manual—no command needed   |

---

## PRD Template (Generated by Wizard)

When `/feature` creates a PRD, it includes:

```markdown
# Feature: Product Search

**Status:** Draft (awaiting approval)  
**Requested by:** @alice  
**Owner:** @alice  
**Created:** 2026-04-01

---

## Overview

Members can search for products by name and category, with results ranked by rating.

---

## User Journey

1. Click search bar
2. Type product name or category
3. See filtered results
4. Click product → read reviews
5. Back to search → refine filters

---

## Services Required

| Service         | Purpose                  | Epic          |
| --------------- | ------------------------ | ------------- |
| search-api      | HTTP endpoint for search | Search        |
| product-indexer | Index products in search | Data Platform |
| SearchResults   | Display results UI       | Design System |

---

## Success Criteria

- [ ] Search returns results in < 200ms
- [ ] Results ranked by rating
- [ ] Mobile responsive
- [ ] 95% of searches successful

---

## Breaking Changes

None. Pure additive feature.

---

## Timeline

- Dev: 3 days
- Staging: 2 days
- Prod canary: 1 day
- Full rollout: 1 day
```

---

## Full Feature Workflow

Once scaffolding is done:

```
1. Implement
   ├─ Write handler.ts logic
   ├─ Write handler.test.ts (90% coverage)
   ├─ Write component.tsx + component.test.tsx
   └─ Update infra/main.tf if needed

2. Test locally
   ├─ npm test (all pass)
   ├─ npm run lint (zero errors)
   └─ terraform validate

3. Create PR
   ├─ Link PRD (Closes PRD-123)
   ├─ Checklist passes
   └─ 2 approvals

4. Deploy
   ├─ Auto → dev
   ├─ Manual → staging (lead approval)
   └─ Manual → prod (lead + VP approval)
```

---

## Choosing Your Approach

### **I Want the Wizard (Fast)**

```
/feature
→ Answer questions
→ Get PRD + all scaffolding
→ Start coding
```

### **I Want Granular Control (Learning)**

```
/lambda search-api
→ Implement
→ /event product.indexed
→ Implement
→ /component SearchResults
→ Implement
→ /diagram
→ Finish
```

### **I Already Know What I'm Doing (Experienced)**

```
mkdir -p platforms/infrastructure/lambdas/search-api/{src,infra}
→ Copy templates from existing similar service
→ Customize
→ Start coding
```

---

## See Also

- [How to Add a Feature](../../../docs/HOW-TO-ADD-A-FEATURE.md) — Full workflow with examples
- [/lambda](./lambda.md) — Scaffold a Lambda function
- [/event](./event.md) — Define an event schema
- [/component](./component.md) — Create a React component
- [Naming Conventions](../rules/naming.md) — Service, file, event naming
