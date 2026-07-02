variable "table_name" {
  type = string
}

variable "hash_key" {
  type = string
}

variable "range_key" {
  type    = string
  default = null
}

variable "attributes" {
  type = any
}

variable "billing_mode" {
  type = string
}

variable "server_side_encryption_kms_key_arn" {
  type = string
}

variable "point_in_time_recovery_enabled" {
  type = bool
}

variable "deletion_protection_enabled" {
  type = bool
}

variable "tags" {
  type = map(string)
}
