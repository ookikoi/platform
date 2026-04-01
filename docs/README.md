# Documentation Index

Welcome to the platform documentation. Start here based on what you need.

---

## For New Developers

**Start here →** [GETTING-STARTED.md](./GETTING-STARTED.md) (30 min read)

This walks you through:

- What the platform is
- Tool prerequisites
- Creating your first Lambda
- Understanding the architecture
- How to promote code through dev → staging → prod

---

## Setting Up Your Local Environment

**Next →** [LOCAL-DEVELOPMENT.md](./LOCAL-DEVELOPMENT.md)

Learn how to:

- Configure AWS credentials
- Set up environment variables
- Run DynamoDB locally
- Run Lambda functions locally
- Test code before deployment

---

## Understanding the System

**Architecture & Design →** [ARCHITECTURE.md](./ARCHITECTURE.md)

Deep dive into:

- Platform layers (Infrastructure, Data, Design System)
- Service domains (Membership, Reviews, Search, Recommendations)
- Event flows and data models
- How services communicate

---

## Adding a New Feature

**Feature Workflow →** [HOW-TO-ADD-A-FEATURE.md](./HOW-TO-ADD-A-FEATURE.md)

Complete walkthrough for:

- When to write a PRD
- Breaking down a feature into services
- Creating Lambdas, events, components
- Testing & code review
- Deploying through environments

**Also see:** [.github/pull_request_template.md](../.github/pull_request_template.md) — PR checklist

---

## Deploying Code

**Deployment Guide →** [DEPLOYMENT.md](./DEPLOYMENT.md)

Instructions for:

- Deploying to dev (automatic)
- Deploying to staging (manual)
- Deploying to production (with approvals)
- Rolling back if something breaks
- Monitoring deployments

**Approval Gates →** [../workflows/APPROVAL-GATES.md](../workflows/APPROVAL-GATES.md)

Understand:

- Code review requirements
- Deployment stages and approvals
- When to rollback
- Feature flags

---

## Something Doesn't Work?

**Troubleshooting →** [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)

Common issues and fixes for:

- npm / Node.js problems
- Testing issues
- Terraform errors
- AWS / DynamoDB errors
- Lambda issues
- Deployment problems

---

## When Production Breaks

**Incident Response →** [../workflows/runbooks/incident-response.md](../workflows/runbooks/incident-response.md)

Step-by-step procedures for:

- Detecting incidents
- Assessing severity
- Diagnostics
- Escalation
- Communication

**Rollback Procedure →** [../workflows/runbooks/prod-rollback.md](../workflows/runbooks/prod-rollback.md)

How to revert a bad deployment in production.

---

## Rules & Standards

**Platform Rules:**

- [Security](../.claude/rules/security.md) — Secrets, IAM, input validation
- [Naming](../.claude/rules/naming.md) — Conventions for services, files, events
- [AWS](../.claude/rules/aws.md) — Lambda defaults, Terraform patterns, regions
- [Testing](../.claude/rules/testing.md) — Coverage floors, what to test
- [Design System](../.claude/rules/design-system.md) — Tokens, components, a11y

---

## Reference

| Topic                          | Where                                                                                   |
| ------------------------------ | --------------------------------------------------------------------------------------- |
| What is this platform?         | [../CLAUDE.md](../CLAUDE.md)                                                            |
| System architecture diagram    | [../architecture/system-map.md](../architecture/system-map.md)                          |
| User registration flow example | [../architecture/flow-user-registration.md](../architecture/flow-user-registration.md)  |
| **Custom Commands**            | **[../.claude/commands/README.md](../.claude/commands/README.md)**                      |
| Create a feature (wizard)      | `/feature` (see [../.claude/commands/feature.md](../.claude/commands/feature.md))       |
| Create a Lambda                | `/lambda` (see [../.claude/commands/lambda.md](../.claude/commands/lambda.md))          |
| Create a UI component          | `/component` (see [../.claude/commands/component.md](../.claude/commands/component.md)) |
| Define an event                | `/event` (see [../.claude/commands/event.md](../.claude/commands/event.md))             |

---

## Document Map

```
docs/
├── README.md (you are here)
├── GETTING-STARTED.md        ← Start here for onboarding
├── HOW-TO-ADD-A-FEATURE.md   ← Feature workflow (PRD → Lambdas → Deploy)
├── LOCAL-DEVELOPMENT.md      ← Run code locally
├── ARCHITECTURE.md           ← Understand the system
├── DEPLOYMENT.md             ← Deploy to staging/prod
├── TROUBLESHOOTING.md        ← Fix common errors
└── .env.example              ← Template for env vars

.claude/
├── rules/
│   ├── security.md
│   ├── naming.md
│   ├── aws.md
│   ├── testing.md
│   └── design-system.md
├── commands/
│   ├── README.md              ← Index of all commands
│   ├── feature.md             ← Interactive wizard
│   ├── lambda.md              ← Create Lambda
│   ├── component.md           ← Create React component
│   └── event.md               ← Define event
└── skills/ (advanced usage)

workflows/
├── APPROVAL-GATES.md         ← Deployment stages
├── README.md                 ← Workflow overview
└── runbooks/
    ├── incident-response.md  ← What to do when prod breaks
    ├── prod-rollback.md      ← How to rollback
    └── data-correction.md    ← Fix data inconsistencies
```

---

## Quick Answers

**Q: How do I add a new feature?**  
A: Use `/feature` (interactive wizard) or follow [HOW-TO-ADD-A-FEATURE.md](./HOW-TO-ADD-A-FEATURE.md) for granular control.

**Q: How do I create a new Lambda?**  
A: `invoke /lambda search-api --trigger api` — or see [../.claude/commands/lambda.md](../.claude/commands/lambda.md) for details.

**Q: How do I create an event or component?**  
A: `invoke /event product.created` or `invoke /component SearchResults` — see [../.claude/commands/](../.claude/commands/) for all commands.

**Q: How do I get my code to production?**  
A: Follow [DEPLOYMENT.md](./DEPLOYMENT.md) and [../workflows/APPROVAL-GATES.md](../workflows/APPROVAL-GATES.md).

**Q: Production is on fire, what do I do?**  
A: Read [../workflows/runbooks/incident-response.md](../workflows/runbooks/incident-response.md) immediately.

**Q: How do I debug a failing Lambda locally?**  
A: See [LOCAL-DEVELOPMENT.md](./LOCAL-DEVELOPMENT.md#7-common-development-tasks).

**Q: My tests are failing, how do I fix it?**  
A: Check [TROUBLESHOOTING.md](./TROUBLESHOOTING.md#testing-issues).

**Q: How do I use design system components?**  
A: Read [../.claude/rules/design-system.md](../.claude/rules/design-system.md).

**Q: What's the naming convention for Lambdas?**  
A: See [../.claude/rules/naming.md](../.claude/rules/naming.md#lambdas).

---

## Feedback

If docs are missing, unclear, or outdated:

- Create an issue on GitHub
- Slack: #platform-engineering
- Suggest a fix (PR preferred)

We keep these docs fresh because you use them every day.

---

**Welcome to the team!** 🚀
