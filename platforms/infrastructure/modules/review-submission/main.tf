# Review Submission Lambda Module
# Handles product review submissions from members
# Triggers: review.submitted event on EventBridge

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "environment" {
  type = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Must be dev, staging, or prod."
  }
}

variable "reviews_table_name" {
  type = string
}

variable "event_bus_name" {
  type = string
}

# DLQ
resource "aws_sqs_queue" "dlq" {
  name                      = "review-submission-${var.environment}-dlq"
  message_retention_seconds = 1209600

  tags = local.tags
}

# Role
resource "aws_iam_role" "lambda_role" {
  name = "review-submission-${var.environment}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Permissions: write to DynamoDB, write to EventBridge
resource "aws_iam_role_policy" "permissions" {
  name = "review-submission-permissions"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.reviews_table_name}"
      },
      {
        Action = [
          "events:PutEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:events:${var.aws_region}:${data.aws_caller_identity.current.account_id}:event-bus/${var.event_bus_name}"
      },
      {
        Action = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Lambda
resource "aws_lambda_function" "handler" {
  filename      = "${path.module}/dist/index.zip"
  function_name = "review-submission-${var.environment}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "src/handler.handler"
  runtime       = "nodejs22.x"

  memory_size                    = 512
  timeout                        = 30
  reserved_concurrent_executions = var.environment == "prod" ? 50 : 10

  dead_letter_config {
    target_arn = aws_sqs_queue.dlq.arn
  }

  environment {
    variables = {
      REVIEWS_TABLE   = var.reviews_table_name
      EVENT_BUS_NAME  = var.event_bus_name
      NODE_OPTIONS    = "--enable-source-maps"
    }
  }

  tracing_config {
    mode = "Active"
  }

  tags = local.tags

  depends_on = [
    aws_iam_role_policy_attachment.basic,
    aws_iam_role_policy.permissions
  ]
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "/aws/lambda/review-submission-${var.environment}"
  retention_in_days = 30

  tags = local.tags
}

# HTTP API endpoint
variable "api_gateway_id" {
  type = string
}

variable "api_stage_name" {
  type = string
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id           = var.api_gateway_id
  integration_type = "AWS_PROXY"
  integration_method = "POST"
  payload_format_version = "2.0"
  target_uri       = aws_lambda_function.handler.invoke_arn
}

resource "aws_apigatewayv2_route" "post_review" {
  api_id    = var.api_gateway_id
  route_key = "POST /reviews"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_lambda_permission" "api" {
  statement_id  = "AllowAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${var.api_gateway_id}/*/*"
}

# Outputs
output "function_arn" {
  value = aws_lambda_function.handler.arn
}

output "function_name" {
  value = aws_lambda_function.handler.function_name
}

# Data
data "aws_caller_identity" "current" {}

variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

locals {
  tags = {
    Environment = var.environment
    Service     = "review-submission"
    Owner       = "platform-team"
    CostCentre  = "engineering"
  }
}
