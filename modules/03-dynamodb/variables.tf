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

variable "hash_key" {
  description = "DynamoDB event-store partition key attribute name."
  type        = string
  default     = "event_id"
}

variable "range_key" {
  description = "DynamoDB sort key attribute name. Leave empty for no sort key."
  type        = string
  default     = "event_time"
}

variable "billing_mode" {
  description = "DynamoDB billing mode: PAY_PER_REQUEST or PROVISIONED."
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "point_in_time_recovery_enabled" {
  description = "Enable point-in-time recovery for the event-store table."
  type        = bool
  default     = false
}

variable "deletion_protection_enabled" {
  description = "Prevent accidental deletion of the event-store table."
  type        = bool
  default     = false
}
