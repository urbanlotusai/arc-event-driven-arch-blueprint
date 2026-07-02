# =============================================================================
# Module: 04-sns
# =============================================================================
# Provisions the SNS fan-out topic that producers publish events to.
# State file: modules/04-sns/terraform.tfstate
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
# SNS Module
# -----------------------------------------------------------------------------

module "sns" {
  source  = "sourcefuse/arc-sns/aws"
  version = "0.0.4"

  name              = "${var.namespace}-${var.environment}-events"
  kms_master_key_id = data.terraform_remote_state.kms.outputs.key_id

  # Wire the SQS queue (03-sqs remote state) as a subscriber after both
  # modules exist. Use a separate aws_sns_topic_subscription resource or the
  # subscriptions map:
  # subscriptions = {
  #   "event-processor" = {
  #     protocol              = "sqs"
  #     endpoint              = data.terraform_remote_state.sqs.outputs.queue_arn
  #     raw_message_delivery  = true
  #   }
  # }

  tags = var.tags
}
