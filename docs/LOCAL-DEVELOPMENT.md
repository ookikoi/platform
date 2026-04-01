# Local Development Setup

Run and test code locally before deploying to AWS.

---

## Prerequisites

```bash
# Node.js 22+
node --version

# Terraform
terraform --version

# AWS CLI
aws --version

# Docker (for DynamoDB Local)
docker --version
```

---

## 1. AWS Credentials

### Configure AWS CLI

```bash
aws configure --profile company-platform
# Enter Access Key, Secret Key
# Region: eu-west-1
# Output: json

# Test it
aws sts get-caller-identity --profile company-platform
```

### Use in Development

```bash
# Option A: Export to environment
export AWS_PROFILE=company-platform

# Option B: Add to .bashrc or .zshrc
echo 'export AWS_PROFILE=company-platform' >> ~/.zshrc
source ~/.zshrc

# Verify
echo $AWS_PROFILE
```

---

## 2. Environment Variables

Create `.env` file in project root:

```bash
cp docs/.env.example .env
```

Edit `.env`:

```
# AWS
AWS_PROFILE=company-platform
AWS_REGION=eu-west-1

# Database
DYNAMODB_ENDPOINT=http://localhost:8000  # For local DynamoDB
MEMBERS_TABLE=members-dev
REVIEWS_TABLE=reviews-dev
PRODUCTS_TABLE=products-dev

# Event Bus
EVENT_BUS_NAME=platform-events-dev

# Feature Flags
NODE_ENV=development
DEBUG=true
```

Load in your terminal:

```bash
source .env
```

Or in Node code:

```typescript
import dotenv from "dotenv";
dotenv.config();

const tableNa = process.env.MEMBERS_TABLE;
```

---

## 3. Run DynamoDB Locally

### Start DynamoDB Local (Docker)

```bash
# Pull image (first time only)
docker pull amazon/dynamodb-local

# Start DynamoDB on port 8000
docker run -d -p 8000:8000 --name dynamodb-local amazon/dynamodb-local

# Verify
curl http://localhost:8000
```

### Create Tables Locally

```bash
# Create members table
aws dynamodb create-table \
  --table-name members-dev \
  --attribute-definitions AttributeName=memberId,AttributeType=S \
  --key-schema AttributeName=memberId,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --endpoint-url http://localhost:8000 \
  --profile company-platform

# Create reviews table
aws dynamodb create-table \
  --table-name reviews-dev \
  --attribute-definitions \
    AttributeName=reviewId,AttributeType=S \
    AttributeName=productId,AttributeType=S \
  --key-schema \
    AttributeName=reviewId,KeyType=HASH \
    AttributeName=productId,KeyType=RANGE \
  --billing-mode PAY_PER_REQUEST \
  --endpoint-url http://localhost:8000 \
  --profile company-platform
```

### Query Local DynamoDB

```bash
# Get item
aws dynamodb get-item \
  --table-name members-dev \
  --key '{"memberId":{"S":"member-123"}}' \
  --endpoint-url http://localhost:8000 \
  --profile company-platform

# Scan table
aws dynamodb scan \
  --table-name members-dev \
  --endpoint-url http://localhost:8000 \
  --profile company-platform
```

### Stop DynamoDB

```bash
docker stop dynamodb-local
docker rm dynamodb-local
```

---

## 4. Run Lambda Locally

### Using AWS SAM

```bash
# Install SAM CLI
brew install aws-sam-cli

# Start API locally
cd platforms/infrastructure/lambdas/review-list-api
sam local start-api

# Now hit your Lambda
curl http://localhost:3000/reviews?productId=550e8400-e29b-41d4-a716-446655440000
```

### Using Node Directly

```bash
cd platforms/infrastructure/lambdas/review-list-api

# Build
npm run build

# Test via Node
node -e "
const handler = require('./dist/handler').handler;
handler({
  queryStringParameters: { productId: '123-456' }
}).then(console.log);
"
```

### Using Jest Tests

```bash
# Run all tests
npm test

# Run tests for one Lambda
cd platforms/infrastructure/lambdas/review-list-api
npm test

# Run tests in watch mode
npm test -- --watch

# Check coverage
npm test -- --coverage
```

---

## 5. Terraform Local Validation

```bash
# Validate syntax
cd platforms/infrastructure
terraform fmt -check -recursive .

# Fix formatting
terraform fmt -recursive .

# Validate against AWS
terraform init -backend=false
terraform validate

# See what will be created (without applying)
terraform plan -var-file=dev.tfvars
```

---

## 6. IDE Setup

### VSCode Extensions (Recommended)

```json
// Install these extensions:
{
  "recommendations": [
    "hashicorp.terraform",
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "eamodio.gitlens",
    "ms-vscode.makefile-tools"
  ]
}
```

### ESLint + Prettier

```bash
# Already included in package.json
npm install

# Format code
npm run format

# Lint
npm run lint

# Auto-fix lint errors
npm run lint -- --fix
```

### Terraform Extensions

```bash
# VSCode will auto-format .tf files with terraform fmt on save
# Recommended: Install HashiCorp Terraform extension
```

---

## 7. Common Development Tasks

### Build a Lambda

```bash
cd platforms/infrastructure/lambdas/[service-name]
npm run build  # Outputs dist/index.zip
```

### Run Tests

```bash
# All tests
npm test

# Specific test file
npm test -- handler.test.ts

# Watch mode (re-run on change)
npm test -- --watch

# Coverage report
npm test -- --coverage
```

### Lint & Format

```bash
# Check for errors
npm run lint

# Auto-fix
npm run lint -- --fix

# Format with Prettier
npm run format
```

### Debug Lambda

```bash
# Add breakpoint in handler.ts
debugger;

# Run with Node debugger
node --inspect-brk dist/handler.js

# Open chrome://inspect in Chrome
# Click "Inspect" on process
```

### Test Against Local DynamoDB

```typescript
// In tests, use endpoint-url
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";

const client = new DynamoDBClient({
  region: "eu-west-1",
  endpoint: "http://localhost:8000", // Local DynamoDB
});

// Now all queries hit local DB, not AWS
```

### Push Changes

```bash
# Create branch
git checkout -b feature/my-feature

# Make changes, commit
git add .
git commit -m "Add review filtering"

# Push
git push origin feature/my-feature

# Create PR on GitHub
# → Tests run automatically
# → Get approval
# → Merge
# → Auto-deploy to dev
```

---

## 8. Troubleshooting

### "Module not found"

```bash
npm install
npm run build
```

### "Port 8000 already in use"

```bash
# Kill process using port 8000
lsof -ti :8000 | xargs kill -9

# Or use different port
docker run -d -p 8001:8000 amazon/dynamodb-local
export DYNAMODB_ENDPOINT=http://localhost:8001
```

### "AWS credentials not found"

```bash
# Check profile is set
echo $AWS_PROFILE

# Re-configure
aws configure --profile company-platform

# Verify
aws sts get-caller-identity --profile company-platform
```

### "Terraform init fails"

```bash
# Clear cache
rm -rf .terraform terraform.lock.hcl

# Re-init
terraform init -backend=false
```

### "DynamoDB Connection Refused"

```bash
# Is Docker running?
docker ps

# Is DynamoDB container running?
docker ps | grep dynamodb

# Start it
docker run -d -p 8000:8000 --name dynamodb-local amazon/dynamodb-local
```

---

## 9. Full Example: Local Development Workflow

```bash
# 1. Start infrastructure
docker run -d -p 8000:8000 --name dynamodb-local amazon/dynamodb-local
source .env

# 2. Create local tables
aws dynamodb create-table \
  --table-name reviews-dev \
  --attribute-definitions AttributeName=reviewId,AttributeType=S \
  --key-schema AttributeName=reviewId,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --endpoint-url http://localhost:8000

# 3. Develop Lambda
cd platforms/infrastructure/lambdas/review-list-api
npm install

# 4. Write code
# Edit src/handler.ts

# 5. Test locally
npm test -- --watch

# 6. Build & run
npm run build
sam local start-api

# 7. Test via HTTP
curl http://localhost:3000/reviews?productId=test-123

# 8. Push to GitHub
git push origin feature/review-list

# 9. Verify auto-deploy to dev
gh run list  # Watch tests pass

# 10. Done! Code is in dev environment
```

---

## See Also

- [GETTING-STARTED.md](./GETTING-STARTED.md) — Onboarding guide
- [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) — Common issues
- [DEPLOYMENT.md](./DEPLOYMENT.md) — Deploying to staging/prod
