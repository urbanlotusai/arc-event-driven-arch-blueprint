variable "namespace" {
  description = "Organization or team namespace"
  type        = string
  default     = "arc"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Project   = "arc-event-driven-arch-blueprint"
  }
}

variable "state_bucket_name" {
  description = "S3 bucket name for Terraform state (used to read 01-kms remote state)"
  type        = string
}

variable "lambda_s3_bucket" {
  description = "Name of the S3 bucket that holds the Lambda deployment package. Must exist before apply."
  type        = string
}

variable "lambda_s3_key" {
  description = "S3 object key of the Lambda consumer deployment package (e.g. consumers/handler-v1.0.0.zip)."
  type        = string
}

variable "runtime" {
  description = "Lambda runtime identifier."
  type        = string
  default     = "nodejs20.x"
}

variable "handler" {
  description = "Lambda handler entrypoint (file.export, e.g. index.handler)."
  type        = string
  default     = "index.handler"
}

variable "memory_size" {
  description = "Lambda memory allocation in MB."
  type        = number
  default     = 512
}

variable "timeout" {
  description = "Lambda execution timeout in seconds."
  type        = number
  default     = 30
}

variable "reserved_concurrent_executions" {
  description = "Reserved concurrency cap. -1 means unreserved (account pool)."
  type        = number
  default     = -1
}

variable "log_retention_in_days" {
  description = "CloudWatch log group retention for the Lambda consumer."
  type        = number
  default     = 90
}
