# Rule: Security

## Secrets
- NEVER write secrets, keys, tokens, or passwords into source files
- NEVER write `.env` files with real values — only `.env.example` with placeholders
- Secrets live in AWS SSM Parameter Store under `/company/<env>/<service>/<key>`
- Retrieve at runtime: `ssm.getParameter({ Name: '/company/prod/stripe/secret-key' })`

## IAM
- All Lambda execution roles follow least-privilege — only the permissions the function needs
- No `*` actions in IAM policies unless explicitly justified in a comment
- Role names follow the pattern: `<service>-<function>-<env>-role`

## Input validation
- Validate all external input at the Lambda handler boundary using Zod
- Never pass raw event body to internal functions — parse and validate first

## Scanning
- Before completing any /lambda or /api task, mentally check: OWASP API Security Top 10
- Flag any of the following as blockers: broken auth, injection risk, excessive data exposure
