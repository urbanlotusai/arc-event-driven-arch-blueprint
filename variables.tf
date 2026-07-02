# ── Mandatory ─────────────────────────────────────────────────────────────────

variable "environment" {
  description = "Deployment environment (e.g. prod, staging, dev)."
  type        = string
}

variable "namespace" {
  description = "Project or team namespace used as a resource name prefix."
  type        = string
}

variable "lambda_s3_bucket" {
  description = "Name of the S3 bucket that holds the Lambda deployment packages. Must exist before apply."
  type        = string
}

variable "lambda_s3_key" {
  description = "S3 object key of the Lambda consumer deployment package (e.g. consumers/handler-v1.0.0.zip)."
  type        = string
}

# ── Optional ──────────────────────────────────────────────────────────────────

variable "region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-1"
}

variable "compliance_profile" {
  description = "Compliance overlay profile. Drives PITR, log retention, and deletion protection."
  type        = string
  default     = "general"

  validation {
    condition     = contains(["general", "hipaa"], var.compliance_profile)
    error_message = "compliance_profile must be one of: general, hipaa."
  }
}

variable "kms_deletion_window" {
  description = "Days before a scheduled KMS key deletion takes effect (7–30)."
  type        = number
  default     = 30
}

variable "dynamodb_hash_key" {
  description = "DynamoDB event-store partition key attribute name."
  type        = string
  default     = "event_id"
}

variable "dynamodb_range_key" {
  description = "DynamoDB sort key attribute name. Leave empty for no sort key."
  type        = string
  default     = "event_time"
}

variable "dynamodb_billing_mode" {
  description = "DynamoDB billing mode: PAY_PER_REQUEST or PROVISIONED."
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "sqs_visibility_timeout" {
  description = "SQS visibility timeout in seconds. Should be at least 6× Lambda timeout."
  type        = number
  default     = 180
}

variable "sqs_message_retention_seconds" {
  description = "SQS message retention period in seconds (60–1209600)."
  type        = number
  default     = 345600
}

variable "lambda_runtime" {
  description = "Lambda runtime identifier."
  type        = string
  default     = "nodejs20.x"
}

variable "lambda_handler" {
  description = "Lambda handler entrypoint (file.export, e.g. index.handler)."
  type        = string
  default     = "index.handler"
}

variable "lambda_memory_size" {
  description = "Lambda memory allocation in MB."
  type        = number
  default     = 512
}

variable "lambda_timeout" {
  description = "Lambda execution timeout in seconds."
  type        = number
  default     = 30
}

variable "archive_retention_days" {
  description = "Days to retain event archive objects in S3 before transitioning to Glacier."
  type        = number
  default     = 90
}
