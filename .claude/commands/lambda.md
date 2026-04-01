# /lambda

Scaffold a production-ready Lambda function following all platform standards.

## Usage

```
/lambda user-profile-get-api
/lambda payment-process-event --trigger event
/lambda report-generate-scheduled --trigger scheduled
```

## Triggers

| Flag                      | Pattern          | Timeout |
| ------------------------- | ---------------- | ------- |
| `--trigger api` (default) | API Gateway HTTP | 30s     |
| `--trigger event`         | EventBridge rule | 5 min   |
| `--trigger scheduled`     | EventBridge cron | 5 min   |

## What gets generated

```
platforms/infrastructure/lambdas/<name>/
├── src/
│   ├── handler.ts          ← entry point, validated input, clean response
│   ├── handler.test.ts     ← unit + integration test stubs
│   └── types.ts            ← Zod schema + inferred types
└── infra/
    └── main.tf             ← Terraform module with role, DLQ, alarms, tags
```

## Prompt sent to Claude

Read `.claude/rules/security.md`, `.claude/rules/naming.md`, `.claude/rules/aws.md`,
`.claude/rules/testing.md`, and `architecture/system-map.md` before generating.

Scaffold a Lambda named: $ARGUMENTS

Apply all rules:

- Validate input with Zod at the handler boundary
- IAM role with least-privilege (stub the specific actions needed)
- DLQ for async triggers
- X-Ray tracing enabled
- SSM for any config — no hardcoded values
- Terraform module with required tags
- Test stubs covering happy path, validation error, auth failure

Write a build log to `artifacts/lambda-<name>-YYYY-MM-DD.md`.
