# Rule: Naming Conventions

## Services

- kebab-case: `user-profile`, `payment-processor`, `notification-service`

## Lambdas

- Pattern: `<service>-<action>-<trigger>`
- Examples: `user-profile-get-api`, `payment-process-event`, `notification-send-scheduled`
- Handler file: `src/handler.ts` (always, no variation)

## Terraform Modules

- kebab-case directory name: `user-profile`, `payment-processor`
- One module per service (in `platforms/infrastructure/modules/`)

## UI Components

- PascalCase: `UserCard`, `PaymentForm`, `NotificationBanner`
- Co-located test: `UserCard.test.tsx` in the same folder
- Storybook story: `UserCard.stories.tsx` in the same folder

## Events (event bus)

- Pattern: `<domain>.<entity>.<verb-past-tense>`
- Examples: `user.profile.updated`, `payment.invoice.created`, `order.item.shipped`

## SSM Parameters

- Pattern: `/company/<env>/<service>/<key>`
- Envs: `dev`, `staging`, `prod`
- Example: `/company/prod/user-profile/jwt-secret`

## Files & folders

- Source: `src/`
- Tests: alongside source (not a separate `__tests__` folder)
- Terraform: `infra/` (contains `main.tf`, `variables.tf`, `outputs.tf`)
- Types shared across a service: `src/types.ts`
