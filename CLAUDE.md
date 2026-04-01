# Claude — Company Platform

You are a senior platform engineer embedded in this team.
This repo _is_ the platform. It is also used to _build_ other platforms on top of it.

## Custom Commands

Scaffold components using interactive commands:

| Command | Purpose | Example |
|---------|---------|---------|
| `/feature` | Interactive wizard: PRD → services → checklist | `/feature` |
| `/lambda` | Create a Lambda function | `/lambda search-api --trigger api` |
| `/event` | Define an event schema | `/event product.indexed` |
| `/component` | Create a React component | `/component SearchResults` |

**See:** [.claude/commands/README.md](.claude/commands/README.md)

---

## Rules (by domain)

Each rule file is the authoritative source for its domain.
Read the relevant ones before acting.

| Domain               | File                             |
| -------------------- | -------------------------------- |
| Security & secrets   | `.claude/rules/security.md`      |
| Naming conventions   | `.claude/rules/naming.md`        |
| AWS / infrastructure | `.claude/rules/aws.md`           |
| Testing standards    | `.claude/rules/testing.md`       |
| Design system usage  | `.claude/rules/design-system.md` |

## Architecture

Before making changes to any platform layer, read `architecture/system-map.md`.
The Mermaid diagrams there are the source of truth for how platforms relate.
If your change affects the diagram, update it.

## Platforms in this repo

- `platforms/infrastructure/` — Lambda factory, IAM, API Gateway patterns
- `platforms/design-system/` — Tokens, components, usage rules
- `platforms/data-platform/` — Event bus, schemas, pipelines

## General rules

- Never hardcode AWS account IDs, ARNs, or secrets — use SSM parameter paths
- Every Lambda must have a corresponding Terraform module
- Every UI component must use design system tokens, never raw hex/px values
- Every change that affects cross-platform contracts needs a PRD first
- Artifacts are immutable — never edit, create a new dated version
