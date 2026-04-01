# Troubleshooting

Common errors and how to fix them.

---

## Development Issues

### "npm ERR! 404 Not Found"

**Symptom:** `npm install` fails  
**Cause:** Package not found in npm registry

**Fix:**

```bash
# Clear npm cache
npm cache clean --force

# Check package name spelling
npm search package-name

# Try again
npm install
```

---

### "TypeError: Cannot find module 'zod'"

**Symptom:** `npm test` fails with missing module  
**Cause:** Dependencies not installed

**Fix:**

```bash
npm ci  # Use ci (clean install) instead of install
npm test
```

---

### "ENOENT: no such file or directory, open '.env'"

**Symptom:** Code trying to load .env file  
**Cause:** .env file not created

**Fix:**

```bash
cp docs/.env.example .env
source .env  # Load variables
```

---

### "Terraform init fails"

**Symptom:** `Error: error reading schema registry endpoint`  
**Cause:** Terraform state backend misconfigured or Terraform cache corrupted

**Fix:**

```bash
# Clear local cache
rm -rf .terraform
rm terraform.lock.hcl

# Re-init (skip backend for local dev)
terraform init -backend=false

# Validate
terraform validate
```

---

### "Module not found after npm install"

**Symptom:** TypeScript error: `Cannot find module 'express'`  
**Cause:** Node modules not installed in that directory

**Fix:**

```bash
# Are you in the right directory?
pwd

# Should end with: .../review-list-api
# If not:
cd platforms/infrastructure/lambdas/review-list-api

# Install
npm install

# Rebuild
npm run build

# Test
npm test
```

---

## Testing Issues

### "Test fails: 'process.env.TABLE_NAME is undefined'"

**Symptom:** Tests fail because env vars not set  
**Cause:** .env not loaded in test environment

**Fix:**

```bash
# Load before running tests
source .env && npm test

# Or add to package.json scripts:
{
  "scripts": {
    "test": "jest",
    "test:local": "source .env && jest"
  }
}

# Then run:
npm run test:local
```

---

### "Tests pass locally but fail in CI"

**Symptom:** GitHub Actions shows failures, local tests pass  
**Cause:** CI environment variables not set

**Fix:**

1. Check `.github/workflows/test.yml` for env vars
2. Add missing vars to GitHub Secrets
3. Or commit sample `.env.test` file

```bash
# Create test env
cat > .env.test <<EOF
NODE_ENV=test
AWS_REGION=eu-west-1
TABLE_NAME=test-table
EOF

# Use in CI:
source .env.test && npm test
```

---

### "Jest timeout: test did not complete within 5000ms"

**Symptom:** `Timeout - Async callback was not invoked`  
**Cause:** Test is waiting for something (DynamoDB, API) that never responds

**Fix:**

```typescript
// Increase timeout
it("should save to DynamoDB", async () => {
  // ...
  expect(result).toBe(true);
}, 10000); // 10 second timeout

// Or check if you're mocking correctly
jest.mock("@aws-sdk/client-dynamodb");
```

---

## Terraform Issues

### "Error: Invalid or missing values for headers"

**Symptom:** Terraform apply fails  
**Cause:** AWS credentials not found or invalid

**Fix:**

```bash
# Check profile
echo $AWS_PROFILE  # Should output: company-platform

# If not set:
export AWS_PROFILE=company-platform

# Verify credentials
aws sts get-caller-identity

# If fails, re-configure:
aws configure --profile company-platform
```

---

### "Error opening S3 object: NoSuchBucket"

**Symptom:** `terraform init` fails  
**Cause:** Terraform state bucket doesn't exist or wrong account

**Fix:**

```bash
# Use local state for development
terraform init -backend=false

# For production, ensure S3 bucket exists
aws s3 ls | grep terraform-state

# If missing, create it
aws s3 mb s3://company-terraform-state-prod --region eu-west-1
```

---

### "Error: resource is in use and cannot be destroyed"

**Symptom:** `terraform destroy` fails  
**Cause:** AWS resource has dependencies

**Fix:**

```bash
# Don't force-delete, instead:
# 1. Check what's using this resource
aws ec2 describe-security-groups --filters Name=group-id,Values=sg-123

# 2. Remove dependencies manually in AWS console
# 3. Then destroy
terraform destroy

# Or skip it for now:
terraform state rm aws_security_group.example
# (Resource stays in AWS, Terraform forgets about it)
```

---

### "Error: Conflicting configuration arguments"

**Symptom:** Terraform plan fails with config conflict  
**Cause:** Two blocks trying to set same parameter

**Fix:**

```hcl
# Wrong: both setting memory_size
resource "aws_lambda_function" "handler" {
  memory_size = 512
  memory_size = 1024  # ❌ Conflict
}

# Right: only one
resource "aws_lambda_function" "handler" {
  memory_size = 512
}
```

---

## AWS / DynamoDB Issues

### "DynamoDB connection refused"

**Symptom:** `Error: connect ECONNREFUSED 127.0.0.1:8000`  
**Cause:** Local DynamoDB not running

**Fix:**

```bash
# Is Docker running?
docker ps

# Is DynamoDB container running?
docker ps | grep dynamodb-local

# If not, start it
docker run -d -p 8000:8000 --name dynamodb-local amazon/dynamodb-local

# Verify
curl http://localhost:8000
# Should return output (not "connection refused")
```

---

### "ProvisionedThroughputExceededException"

**Symptom:** DynamoDB errors during load test  
**Cause:** Provisioned capacity too low

**Fix:**

```bash
# Development: use on-demand
terraform apply -var=billing_mode=PAY_PER_REQUEST

# Production: increase provisioned
terraform apply -var=read_capacity_units=200 -var=write_capacity_units=200

# Or check current capacity
aws dynamodb describe-table --table-name members-prod \
  --profile company-platform
```

---

### "ValidationException: One or more parameter values were invalid"

**Symptom:** DynamoDB query fails with validation error  
**Cause:** Wrong data type or missing attribute

**Example:**

```typescript
// ❌ Wrong: string as number
await dynamodb.getItem({
  Key: { age: { N: "thirty" } }, // Should be "30"
});

// ✅ Right
await dynamodb.getItem({
  Key: { age: { N: "30" } },
});
```

---

### "Access Denied" on DynamoDB

**Symptom:** `User is not authorized to perform: dynamodb:GetItem`  
**Cause:** IAM role missing permission

**Fix:**

```hcl
# In Terraform, add permission
resource "aws_iam_role_policy" "dynamodb" {
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Statement = [{
      Action = ["dynamodb:GetItem", "dynamodb:Query"]
      Effect = "Allow"
      Resource = "arn:aws:dynamodb:*:*:table/members-*"
    }]
  })
}

# Deploy
terraform apply
```

---

## Lambda Issues

### "timeout: the operation timed out"

**Symptom:** Lambda times out after 30 seconds  
**Cause:** Code is slow or waiting on external service

**Fix:**

```bash
# 1. Check what it's waiting for
aws logs tail /aws/lambda/review-list-api-dev --follow

# 2. Increase timeout
terraform apply -var=lambda_timeout=60  # seconds

# 3. Optimize code
# - Cache database connections
# - Use async/parallel queries
# - Reduce payload size
```

---

### "Lambda: UnknownError"

**Symptom:** `Error: Runtime.UnknownError`  
**Cause:** Lambda crashed (usually JSON parse error)

**Fix:**

```bash
# Check logs
aws logs tail /aws/lambda/review-list-api-dev --follow --max-items=50

# Look for actual error message
# Common: JSON.parse() on invalid JSON
# Fix: add try/catch

# Check handler signature
// ✅ Correct
export const handler: APIGatewayProxyHandlerV2 = async (event) => { ... }

// ❌ Wrong (missing async/return type)
export const handler = (event) => { ... }
```

---

### "Lambda code zip file is invalid"

**Symptom:** `The provided zip file is invalid`  
**Cause:** Zip file is empty or corrupted

**Fix:**

```bash
cd platforms/infrastructure/lambdas/review-list-api

# Rebuild
npm run build

# Check zip file
ls -lh dist/index.zip
# Should be > 1KB

# Verify zip
unzip -l dist/index.zip | head
# Should show files like: src/handler.js
```

---

## Deployment Issues

### "GitHub Actions test fails but code looks fine"

**Symptom:** Local tests pass, GitHub Actions fails  
**Cause:** Different environment or missing env vars

**Fix:**

1. Check `.github/workflows/test.yml` for secrets
2. Set missing secrets in GitHub Settings
3. Or update workflow to use `.env.test`

```bash
# Test with CI-like environment
source .env.test && npm test
```

---

### "deploy-staging.yml approval never appears"

**Symptom:** Workflow is stuck waiting for approval  
**Cause:** Environment protection not configured

**Fix:**

1. Go to GitHub Repo Settings → Environments
2. Create environment: `staging-approval`
3. Add reviewers
4. Configure deployment branches (main only)

---

### "Terraform apply hangs"

**Symptom:** `terraform apply` never completes  
**Cause:** AWS API slow or network issue

**Fix:**

```bash
# Ctrl+C to cancel
# Check AWS status
# https://status.aws.amazon.com/

# Try again with verbose output
TF_LOG=DEBUG terraform apply

# Or check if resource is stuck
aws dynamodb describe-table --table-name members-prod
```

---

## Production Incidents

### "Production Lambda returning 500 errors"

**Symptom:** Users see "Internal Server Error"  
**Cause:** Code bug, permission issue, or downstream service down

**Response:**

1. Run [incident response runbook](../workflows/runbooks/incident-response.md)
2. Check CloudWatch logs
3. If bad code: run [rollback runbook](../workflows/runbooks/prod-rollback.md)

---

### "DynamoDB throttling in production"

**Symptom:** Errors like `ProvisionedThroughputExceeded`  
**Cause:** Capacity set too low

**Response:**

```bash
# Immediate: increase capacity
terraform apply -var=write_capacity_units=500

# Investigate: which table is hot?
aws cloudwatch get-metric-statistics \
  --namespace AWS/DynamoDB \
  --metric-name ConsumedWriteCapacityUnits \
  --dimensions Name=TableName,Value=reviews-prod \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum
```

---

## Ask for Help

| Issue           | Who to Ask               |
| --------------- | ------------------------ |
| Terraform error | #platform-infrastructure |
| Lambda/Node.js  | #platform-engineering    |
| AWS permissions | platform-lead            |
| Data corruption | #data-platform           |

---

## See Also

- [GETTING-STARTED.md](./GETTING-STARTED.md)
- [LOCAL-DEVELOPMENT.md](./LOCAL-DEVELOPMENT.md)
- [DEPLOYMENT.md](./DEPLOYMENT.md)
- [Incident Response](../workflows/runbooks/incident-response.md)
- [Prod Rollback](../workflows/runbooks/prod-rollback.md)
