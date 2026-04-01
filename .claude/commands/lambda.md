# Command: /lambda

Scaffold a production-ready Lambda function with handler, tests, types, and Terraform infrastructure. Full hands-on control over service creation.

---

## Usage

```
/lambda <service-name> [--trigger <type>] [--description "..."]
```

### Parameters

| Parameter       | Required | Options                     | Example                        |
| --------------- | -------- | --------------------------- | ------------------------------ |
| `service-name`  | Yes      | kebab-case                  | `search-api`, `review-indexer` |
| `--trigger`     | No       | `api`, `event`, `scheduled` | `--trigger event`              |
| `--description` | No       | Any string                  | `"Index reviews when created"` |

**Default:** `--trigger api` if not specified

---

## What Gets Created

```
platforms/infrastructure/lambdas/<service-name>/
├── src/
│   ├── handler.ts              ← Async function with validated input
│   ├── handler.test.ts         ← Unit + integration test stubs
│   ├── types.ts                ← Zod schemas + TypeScript types
│   └── index.ts                ← Exports handler
├── infra/
│   ├── main.tf                 ← Lambda, IAM role, DLQ, X-Ray, logs
│   ├── variables.tf            ← Environment, service name, tags
│   └── outputs.tf              ← Lambda ARN, role ARN
├── package.json                ← Dependencies (zod, aws-sdk)
└── .env.example                ← Template for AWS_REGION, TABLE_NAME, etc.
```

---

## Quick Examples

```bash
# Create an API endpoint
/lambda search-api --trigger api --description "Search products by name"

# Create an event processor
/lambda review-indexer --trigger event --description "Index reviews when created"

# Create a scheduled job
/lambda stats-aggregator --trigger scheduled --description "Nightly rating aggregation"
```

---

## Next Steps After Creation

1. **Edit `src/handler.ts`** — Add business logic
2. **Edit `src/types.ts`** — Refine Zod schemas
3. **Edit `src/handler.test.ts`** — Write real tests (90%+ coverage required)
4. **Edit `infra/main.tf`** — Add extra IAM permissions if needed
5. **Run locally:** `npm test` or `sam local start-api`
6. **Push to git** — Auto-deploys to dev
7. **Wire to other services** — Use `/event` for event schemas, `/diagram` to update architecture

---

## See Also

- [Naming Conventions](../rules/naming.md#lambdas) — Service naming
- [AWS Rules](../rules/aws.md#lambda-defaults) — Memory, timeout, concurrency
- [Testing Standards](../rules/testing.md#lambda-testing-layers) — Coverage requirements
- [Security](../rules/security.md#input-validation) — Validation, secrets, IAM
- [How to Add a Feature](../../../docs/HOW-TO-ADD-A-FEATURE.md) — Workflow context
