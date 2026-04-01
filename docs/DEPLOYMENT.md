# Deployment Guide

---

## Prerequisites

```bash
# Install tools
brew install terraform aws-cli node

# Configure AWS credentials
aws configure --profile company-platform

# Log in to Terraform Cloud (optional)
terraform login
```

---

## Deployment Checklist

### 1. Data Platform (one-time)

The data platform (DynamoDB, EventBridge, S3) is the foundation. Deploy once per environment.

```bash
cd platforms/data-platform
terraform init
terraform plan -var-file=prod.tfvars
terraform apply
```

**Resources created:**

- DynamoDB tables (members, reviews, products, ratings)
- EventBridge event bus `platform-events`
- S3 data lake bucket `platform-datalake-prod`

---

### 2. Infrastructure Platform

Deploy reusable infrastructure: Lambda execution roles, API Gateway, VPC, IAM policies.

```bash
cd platforms/infrastructure
terraform init
terraform plan -var-file=prod.tfvars
terraform apply
```

---

### 3. Lambda Services

Deploy individual services. Each service is a Terraform module.

```bash
# Example: Deploy member profile service
cd platforms/infrastructure/modules/member-profile
terraform init
terraform plan \
  -var=environment=prod \
  -var=members_table_name=members-prod
terraform apply
```

**Build first:**

```bash
cd platforms/infrastructure/lambdas/member-profile-get-api
npm install
npm run build  # Outputs dist/index.zip
```

---

## Deploying a New Lambda

1. Create scaffold using `/lambda` command
2. Implement handler + tests
3. Run tests: `npm test`
4. Build: `npm run build`
5. Deploy Terraform:
   ```bash
   terraform init
   cd infra/
   terraform apply -var=environment=prod
   ```

---

## Environment Promotion

```
dev → staging → prod
```

Each environment has its own `.tfvars` file:

```bash
# Dev
terraform apply -var-file=dev.tfvars

# Staging (mirrors prod config, lower reserved concurrency)
terraform apply -var-file=staging.tfvars

# Prod (highest concurrency, backup enabled)
terraform apply -var-file=prod.tfvars
```

---

## Rollback

```bash
# Check history
terraform state list
terraform show

# Rollback to previous state
terraform apply -refresh=true  # Re-fetches live state
terraform state pull > backup.tfstate

# Manual rollback (use backup)
terraform state push backup.tfstate
```

---

## Monitoring Deployment

```bash
# Watch CloudWatch logs
aws logs tail /aws/lambda/member-profile-get-api-prod --follow

# Check Lambda metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Duration \
  --dimensions Name=FunctionName,Value=member-profile-get-api-prod \
  --start-time 2026-04-01T00:00:00Z \
  --end-time 2026-04-02T00:00:00Z \
  --period 3600 \
  --statistics Average,Maximum
```

---

## Cost Monitoring

```bash
# Estimate cost before applying
terraform plan -out=plan.tfplan
# Review Lambda memory, reserved concurrency, DynamoDB mode
```

**Key cost drivers:**

- Lambda memory (512 MB default)
- Reserved concurrency (prod: 50, dev: 10)
- DynamoDB (on-demand for dev/staging, provisioned for prod)
- Data transfer across regions (DR setup)

---

## Troubleshooting

### Lambda won't start

```bash
# Check role permissions
aws iam get-role-policy --role-name member-profile-get-api-prod-role --policy-name ...

# Check CloudWatch logs
aws logs tail /aws/lambda/member-profile-get-api-prod --follow
```

### DynamoDB throttling

```bash
# Check provisioned capacity
aws dynamodb describe-table --table-name members-prod

# Increase capacity
terraform apply -var=dynamodb_rcu=100
```

### EventBridge events not flowing

```bash
# Check rule targets
aws events list-targets-by-rule --rule review-submitted-processor

# Test by sending event
aws events put-events --entries file://test-event.json
```

---

## See Also

- [Architecture](./ARCHITECTURE.md) — System design
- [Testing](./TESTING.md) — How to test Lambdas
- [Troubleshooting](./TROUBLESHOOTING.md) — Common issues
