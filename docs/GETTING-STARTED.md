# Getting Started

Welcome to the platform! This guide will get you productive in 30 minutes.

---

## What You Need to Know (2 min)

This is a **platform of platforms** — a shared infrastructure layer that teams use to build services.

**Three core platforms:**

1. **Infrastructure** — Lambda factory, API Gateway, IAM (Terraform)
2. **Data** — DynamoDB, EventBridge, S3 (shared tables & events)
3. **Design System** — React components, tokens, patterns

**Tech stack:** Node.js 22 + TypeScript + Terraform + AWS

---

## Prerequisites (5 min)

Install these tools:

```bash
# Node.js 22
brew install node@22
node --version  # Should be v22.x.x

# Terraform
brew install terraform
terraform -v  # Should be 1.5+

# AWS CLI
brew install awscli
aws --version

# Git (probably already have it)
git --version
```

---

## Setup (10 min)

### 1. Clone the Repo

```bash
git clone https://github.com/company/platform.git
cd platform
npm install
```

### 2. Configure AWS

```bash
# Log in to AWS console, go to IAM → Create access key
# (Or ask your ops team for credentials)

aws configure --profile company-platform
# Enter Access Key ID
# Enter Secret Access Key
# Region: eu-west-1
# Output format: json

# Verify
aws sts get-caller-identity --profile company-platform
```

### 3. Understand the Rules

**Read these (10 min):**

- [CLAUDE.md](../CLAUDE.md) — Platform principles
- [architecture/system-map.md](../architecture/system-map.md) — System design
- [.claude/rules/aws.md](../.claude/rules/aws.md) — Lambda defaults

**Key principles:**

- Every Lambda has Terraform + tests
- All input validated with Zod
- Design system tokens, never hardcoded colors/sizes
- Secrets in SSM, never in code

---

## Your First Task: Create a Lambda (10 min)

Ready to build something? Let's create a simple Lambda function.

### 1. Use the Scaffold Command

```bash
# Follow the /lambda command (documented in .claude/commands/lambda.md)
# Example: create a Lambda that lists product reviews

/lambda review-list-api

# This creates:
# platforms/infrastructure/lambdas/review-list-api/
# ├── src/handler.ts          (entry point)
# ├── src/handler.test.ts     (test stubs)
# ├── src/types.ts            (Zod schemas)
# └── infra/
#     ├── main.tf             (Terraform)
#     ├── variables.tf        (inputs)
#     └── outputs.tf          (outputs)
```

### 2. Implement the Handler

```typescript
// src/handler.ts
import { APIGatewayProxyHandlerV2 } from "aws-lambda";
import { z } from "zod";

const querySchema = z.object({
  productId: z.string().uuid(),
});

export const handler: APIGatewayProxyHandlerV2 = async (event) => {
  try {
    const query = querySchema.parse(event.queryStringParameters);

    // Call business logic
    const reviews = await getReviews(query.productId);

    return {
      statusCode: 200,
      body: JSON.stringify(reviews),
    };
  } catch (error) {
    if (error instanceof z.ZodError) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: error.errors[0].message }),
      };
    }
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Internal error" }),
    };
  }
};

async function getReviews(productId: string) {
  // TODO: Query DynamoDB
  return [];
}
```

### 3. Write Tests

```typescript
// src/handler.test.ts
import { handler } from "./handler";

describe("review-list-api", () => {
  it("returns reviews for a product", async () => {
    const event = {
      queryStringParameters: {
        productId: "550e8400-e29b-41d4-a716-446655440000",
      },
    } as any;

    const result = await handler(event);
    expect(result.statusCode).toBe(200);
  });

  it("rejects invalid product ID", async () => {
    const event = {
      queryStringParameters: { productId: "not-a-uuid" },
    } as any;

    const result = await handler(event);
    expect(result.statusCode).toBe(400);
  });
});
```

### 4. Deploy to Dev

```bash
cd platforms/infrastructure/lambdas/review-list-api
npm install
npm test        # Run tests locally
npm run build   # Compile TypeScript → dist/index.zip

cd infra/
terraform init  # First time only
terraform plan -var=environment=dev
terraform apply
```

**Result:** Your Lambda is deployed to dev! 🎉

---

## Deploy to Staging & Production

Once your Lambda is tested in dev:

```bash
# 1. Create a PR, get it reviewed
git push origin feature/review-list

# 2. Merge to main (triggers auto-deploy to dev)
# Tests run automatically ✅

# 3. Promote to staging
# Click "Run workflow" → deploy-staging.yml
# Wait for approval, then click "Approve"

# 4. Promote to production
# Click "Run workflow" → deploy-prod.yml
# Wait for multi-stage approval

# You can monitor progress in GitHub Actions
gh run list
gh run view <run-id>
```

See [workflows/APPROVAL-GATES.md](../workflows/APPROVAL-GATES.md) for details.

---

## Understand Your Service

Now that your Lambda is deployed, understand the full lifecycle:

### **Data Flow**

```
User (via App)
    ↓
API Gateway (HTTP endpoint)
    ↓
Your Lambda (review-list-api)
    ↓
DynamoDB (query reviews table)
    ↓
Return JSON to user
```

### **Where Your Lambda Lives**

- **Code:** `platforms/infrastructure/lambdas/review-list-api/src/handler.ts`
- **Infrastructure:** `platforms/infrastructure/lambdas/review-list-api/infra/main.tf`
- **Deployed as:** `review-list-api-dev`, `review-list-api-staging`, `review-list-api-prod`

### **Who Else Uses It**

- If your Lambda emits events, they flow through EventBridge
- Other services subscribe to those events
- See: `platforms/data-platform/README.md` for event bus

---

## Common Next Steps

### Add a Dependency

```bash
cd platforms/infrastructure/lambdas/review-list-api
npm install lodash-es
npm install --save-dev @types/lodash-es
```

### Update Your Terraform

If you need DynamoDB access, add to `infra/main.tf`:

```hcl
# Add permission to read reviews table
resource "aws_iam_role_policy" "dynamodb_policy" {
  name = "review-list-dynamodb"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = ["dynamodb:Query", "dynamodb:GetItem"]
      Effect = "Allow"
      Resource = "arn:aws:dynamodb:eu-west-1:*:table/${var.reviews_table_name}"
    }]
  })
}
```

Then deploy: `terraform apply`

### Emit an Event

When something important happens, emit an event for other services:

```typescript
import {
  EventBridgeClient,
  PutEventsCommand,
} from "@aws-sdk/client-eventbridge";

const eventBridge = new EventBridgeClient();

await eventBridge.send(
  new PutEventsCommand({
    Entries: [
      {
        Source: "review-list",
        DetailType: "review.listed",
        Detail: JSON.stringify({ productId, count: reviews.length }),
      },
    ],
  }),
);
```

---

## When You Get Stuck

### **Docs to Read**

| Problem           | Doc                                                                                                    |
| ----------------- | ------------------------------------------------------------------------------------------------------ |
| "How do I...?"    | [ARCHITECTURE.md](./ARCHITECTURE.md) — System overview                                                 |
| Test failing      | [TESTING.md](./TESTING.md) — Testing strategy                                                          |
| Terraform error   | [DEPLOYMENT.md](./DEPLOYMENT.md) — Deployment guide                                                    |
| Lambda timing out | [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) — Common issues                                             |
| Production broken | [workflows/runbooks/incident-response.md](../workflows/runbooks/incident-response.md) — How to respond |

### **Ask for Help**

- Slack: #platform-engineering
- Email: platform-team@company.com
- Sync: Weekly Wed 2pm

---

## Rules to Remember

1. **Never hardcode secrets** → Use SSM Parameter Store
2. **Always validate input** → Use Zod at handler boundary
3. **Use design tokens** → Never `color: '#e94560'`
4. **Test thoroughly** → 90% coverage minimum for Lambdas
5. **Tag everything** → Every resource gets Environment, Service, Owner, CostCentre tags

See [.claude/rules/](../.claude/rules/) for full details.

---

## What You Know Now

✅ Platform structure (Infrastructure, Data, Design System)  
✅ How to scaffold a Lambda  
✅ How to test and deploy  
✅ How to promote through dev → staging → prod  
✅ Where to find help

**Next:** Go build something! 🚀

---

## Related Docs

- [Local Development Setup](./LOCAL-DEVELOPMENT.md) — Run code locally
- [Platform Architecture](./ARCHITECTURE.md) — System design
- [Approval Gates](../workflows/APPROVAL-GATES.md) — Deployment stages
- [Rules](../.claude/rules/) — Naming, security, testing, AWS
