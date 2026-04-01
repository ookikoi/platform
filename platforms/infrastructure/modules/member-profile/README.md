# Member Profile Module

This Terraform module creates a Lambda function for retrieving and updating member profile data.

**Service:** `member-profile-get-api` + `member-profile-update-api`

## Inputs

| Variable             | Type   | Description                        | Default |
| -------------------- | ------ | ---------------------------------- | ------- |
| `environment`        | string | dev / staging / prod               | —       |
| `members_table_name` | string | DynamoDB table for member profiles | —       |
| `api_gateway_id`     | string | HTTP API Gateway ID                | —       |

## Outputs

| Output                | Description            |
| --------------------- | ---------------------- |
| `get_function_arn`    | ARN of GET function    |
| `update_function_arn` | ARN of UPDATE function |
| `table_arn`           | ARN of members table   |

## Usage

```hcl
module "member_profile" {
  source = "../member-profile"

  environment           = var.environment
  members_table_name    = aws_dynamodb_table.members.name
  api_gateway_id        = aws_apigatewayv2_api.main.id
}

output "member_profile_get_arn" {
  value = module.member_profile.get_function_arn
}
```

## Related Events

- `member.profile.updated` — Emitted when profile changes
- `member.subscription.created` — Emitted on signup

## See Also

- [Review Submission Module](../review-submission/) — Similar structure
- [Lambda Template](../../templates/lambda.main.tf) — Base implementation
