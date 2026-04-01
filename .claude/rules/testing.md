# Rule: Testing Standards

## Coverage floors
- Lambda handlers: 90% line coverage minimum
- UI components: 80% line coverage minimum
- Shared utilities: 95% line coverage minimum

## Lambda testing layers
```
Unit tests       — pure business logic, no AWS SDK calls
Integration tests — handler + real DynamoDB (local via docker)
Contract tests   — event schema matches what consumers expect
```

## What must be tested
- Every happy path
- Every validation error path
- Auth failure (401/403)
- Downstream service failure (mock it, test the fallback)
- Cold start safety (no global mutable state that breaks on reuse)

## What NOT to mock
- DynamoDB in integration tests — use DynamoDB Local
- Your own business logic — test it directly

## What to mock
- External third-party APIs (Stripe, SendGrid etc.)
- AWS services other than the one under test
- Time (`jest.useFakeTimers()`) for anything with TTLs or expiry logic

## UI component tests
- Use React Testing Library — no Enzyme
- Test behaviour, not implementation (no `.instance()`, no testing state directly)
- Every component must have: render test, interaction test, accessibility test (axe)
