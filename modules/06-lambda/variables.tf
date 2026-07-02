variable "function_name" {
  type = string
}

variable "s3_bucket" {
  type = string
}

variable "s3_key" {
  type = string
}

variable "kms_key_arn" {
  type = string
}

variable "runtime" {
  type = string
}

variable "handler" {
  type = string
}

variable "memory_size" {
  type = number
}

variable "timeout" {
  type = number
}

variable "reserved_concurrent_executions" {
  type = number
}

variable "log_retention_in_days" {
  type = number
}

variable "tags" {
  type = map(string)
}
