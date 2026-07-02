module "dynamodb" {
  source  = "sourcefuse/arc-dynamodb/aws"
  version = "0.0.1"

  table_name   = var.table_name
  hash_key     = var.hash_key
  range_key    = var.range_key
  attributes   = var.attributes
  billing_mode = var.billing_mode

  server_side_encryption_enabled     = true
  server_side_encryption_kms_key_arn = var.server_side_encryption_kms_key_arn

  point_in_time_recovery_enabled = var.point_in_time_recovery_enabled
  deletion_protection_enabled    = var.deletion_protection_enabled

  tags = var.tags
}
