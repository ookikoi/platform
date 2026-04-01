# Rule: AWS / Infrastructure

## Lambda defaults

Every Lambda function must have:

- Runtime: Node.js 22.x
- Memory: 512 MB (override only with justification in a comment)
- Timeout: 30s for API triggers, 5 min for event/scheduled triggers
- Reserved concurrency: set explicitly (never leave as unreserved)
- Dead letter queue: required for async invocations
- X-Ray tracing: Active

## Terraform patterns

- Use Terraform modules from `platforms/infrastructure/modules/`
- Always tag resources: `{ Environment, Service, Owner, CostCentre }`
- Deploy order: data-platform → infrastructure → application layers

## API Gateway

- All APIs are HTTP API (not REST API) unless REST-specific features needed
- Always enable CORS explicitly — never use `allowOrigins: ['*']` in production
- Auth: JWT authorizer pointing to Cognito unless service-to-service (then IAM)

## Environment config

Never hardcode. Always resolve from environment:

```typescript
const config = {
  jwtSecret: process.env.JWT_SECRET!, // injected from SSM at deploy time
  tableName: process.env.TABLE_NAME!, // injected from Terraform variables
};
```

## Regions

- Primary: `eu-west-1`
- DR: `us-east-1`
- Never deploy to any other region without an ADR

## Cost

- DynamoDB: on-demand billing for dev/staging, provisioned for prod
- Lambda: always check estimated monthly cost before setting high memory/concurrency
