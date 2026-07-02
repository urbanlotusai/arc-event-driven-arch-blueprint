# =============================================================================
# Module: 03-dynamodb
# =============================================================================
# Provisions the DynamoDB event-store table.
# State file: modules/03-dynamodb/terraform.tfstate
# Depends on: 01-kms (encryption key)
# =============================================================================

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.region

  default_tags {
    tags = var.tags
  }
}

# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------

data "terraform_remote_state" "kms" {
  backend = "s3"

  config = {
    bucket = var.state_bucket_name
    key    = "modules/01-kms/terraform.tfstate"
    region = var.region
  }
}

# -----------------------------------------------------------------------------
# DynamoDB Module
# -----------------------------------------------------------------------------

module "dynamodb" {
  source  = "sourcefuse/arc-dynamodb/aws"
  version = "0.0.1"

  table_name   = "${var.namespace}-${var.environment}-event-store"
  hash_key     = var.hash_key
  range_key    = var.range_key != "" ? var.range_key : null
  attributes = concat(
    [{ name = var.hash_key, type = "S" }],
    var.range_key != "" ? [{ name = var.range_key, type = "S" }] : []
  )
  billing_mode = var.billing_mode

  server_side_encryption_enabled     = true
  server_side_encryption_kms_key_arn = data.terraform_remote_state.kms.outputs.key_arn

  point_in_time_recovery_enabled = var.point_in_time_recovery_enabled
  deletion_protection_enabled    = var.deletion_protection_enabled

  tags = var.tags
}
