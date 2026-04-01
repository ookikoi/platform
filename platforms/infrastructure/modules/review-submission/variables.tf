variable "environment" {
  description = "dev | staging | prod"
  type        = string
}

variable "reviews_table_name" {
  description = "DynamoDB table storing review data"
  type        = string
}

variable "event_bus_name" {
  description = "EventBridge bus name for review.submitted events"
  type        = string
}

variable "api_gateway_id" {
  description = "HTTP API Gateway ID"
  type        = string
}

variable "api_stage_name" {
  description = "API Gateway deployment stage"
  type        = string
}

variable "aws_region" {
  description = "AWS region (primary: eu-west-1)"
  type        = string
  default     = "eu-west-1"
}
