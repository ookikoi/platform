# Custom Commands

Invoke these commands in Copilot to scaffold platform components and features.

---

## High-Level Commands

### `/feature` — Interactive Feature Wizard

Create a feature from idea to production.

```
/feature
```

- Answer guided questions about what you're building
- Optionally create a PRD
- Choose: scaffold all services at once, or granular control
- Get an implementation checklist
- Ready to code

**Use this when:** You have a feature idea but don't know what to build  
**See:** [feature.md](./feature.md)

---

## Granular Service Commands

### `/lambda` — Scaffold a Lambda Function

Create a production-ready Lambda with handler, tests, and Terraform.

```
/lambda search-api --trigger api
/lambda review-indexer --trigger event
/lambda stats-aggregator --trigger scheduled
```

**Creates:**
- src/handler.ts (validated request handling)
- src/handler.test.ts (test stubs)
- src/types.ts (Zod schemas)
- infra/main.tf (Terraform)

**Use this when:** You need to create a serverless function  
**See:** [lambda.md](./lambda.md)

---

### `/event` — Define an Event Schema

Create an event type for the event bus (EventBridge).

```
/event user.profile.updated
/event product.review.created
/event payment.invoice.paid
```

**Creates:**
- schema.ts (Zod schema—the contract)
- publisher.ts (typed helper function)
- consumer.ts (EventBridge handler stub)
- schema.test.ts (validation tests)

**Use this when:** Services need to communicate asynchronously  
**See:** [event.md](./event.md)

---

### `/component` — Scaffold a React Component

Create a design-system component with tests and Storybook.

```
/component UserCard
/component ReviewForm --variant modal
/component RatingBadge --description "Show product ratings"
```

**Creates:**
- ComponentName.tsx (React component with tokens only)
- ComponentName.test.tsx (RTL + axe accessibility tests)
- ComponentName.stories.tsx (Storybook story)

**Use this when:** You need to build UI following design system  
**See:** [component.md](./component.md)

---

## Workflow Commands (Coming Soon)

### `/diagram` — Update Architecture

Regenerate system architecture diagrams from your services.

```
/diagram update
```

**See:** [diagram.md](./diagram.md) (reference documentation)

---

## Quick Decision Tree

```
"I want to build a feature"
├─ "I have a PRD or clear idea?"
│  └─ YES → /feature
│           (interactive wizard, guided)
│
├─ "I know I need a Lambda"
│  └─ YES → /lambda search-api --trigger api
│
├─ "Services need to communicate"
│  └─ YES → /event product.created
│
├─ "I'm building UI"
│  └─ YES → /component SearchResults
│
└─ "I want full control, one step at a time"
   └─ YES → Use multiple commands in sequence
```

---

## Full Feature Example

```bash
# Option A: Wizard (guided, automatic)
/feature
    → Creates PRD, all scaffolding, implementation checklist

# Option B: Granular (hands-on, step by step)
/lambda search-api --trigger api
    → Write handler logic, tests
/event product.indexed
    → Define event schema
/component SearchResults
    → Write component, tests, stories
/diagram update
    → Show new event flow in architecture
```

---

## Rules Enforced by Commands

All commands apply these rules automatically:

- [Security](../rules/security.md) — No hardcoded secrets, validated input
- [Naming](../rules/naming.md) — Consistent naming conventions
- [AWS](../rules/aws.md) — Lambda defaults, Terraform patterns
- [Testing](../rules/testing.md) — Coverage requirements, test patterns
- [Design System](../rules/design-system.md) — Tokens only, accessibility

---

## See Also

- [How to Add a Feature](../../docs/HOW-TO-ADD-A-FEATURE.md) — Complete workflow guide
- [Platform Rules](../rules/) — All enforcement rules
- [Getting Started](../../docs/GETTING-STARTED.md) — Onboarding
