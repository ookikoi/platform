variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "table_name" {
  description = "DynamoDB table name for user profiles"
  type        = string
}

variable "aws_region" {
  description = "AWS region (should match primary region from rules)"
  type        = string
  default     = "eu-west-1"
}
