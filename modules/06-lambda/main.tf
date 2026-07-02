# =============================================================================
# Module: 06-lambda
# =============================================================================
# Provisions the Lambda event consumer, triggered by SQS, writing to
# DynamoDB + S3.
# State file: modules/06-lambda/terraform.tfstate
# Depends on: 01-kms (encryption key)
# Add aws_lambda_event_source_mapping after apply to wire SQS -> Lambda.
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
# Lambda Module
# -----------------------------------------------------------------------------

module "lambda" {
  source  = "sourcefuse/arc-lambda-function/aws"
  version = "0.0.2"

  function_name = "${var.namespace}-${var.environment}-event-consumer"

  s3_bucket   = var.lambda_s3_bucket
  s3_key      = var.lambda_s3_key
  kms_key_arn = data.terraform_remote_state.kms.outputs.key_arn

  runtime     = var.runtime
  handler     = var.handler
  memory_size = var.memory_size
  timeout     = var.timeout

  reserved_concurrent_executions = var.reserved_concurrent_executions

  create_log_group      = true
  log_retention_in_days = var.log_retention_in_days

  # Wire event-store context into the function at runtime. Read from the
  # 03-dynamodb and 02-s3 remote states:
  # environment_variables = {
  #   DYNAMODB_TABLE = data.terraform_remote_state.dynamodb.outputs.dynamodb_table_name
  #   ARCHIVE_BUCKET = data.terraform_remote_state.s3.outputs.bucket_id
  #   EVENT_REGION   = var.region
  # }

  tags = var.tags
}
