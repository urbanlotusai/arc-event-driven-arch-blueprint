# ═══════════════════════════════════════════════════════════════════════════════
# 1. KMS — root of the encryption trust chain
#    Outputs consumed by: module.sns, module.sqs, module.dynamodb, module.lambda
# ═══════════════════════════════════════════════════════════════════════════════
module "kms" {
  source  = "sourcefuse/arc-kms/aws"
  version = "1.0.11"

  alias                   = local.kms_alias
  policy                  = data.aws_iam_policy_document.kms.json
  description             = "CMK for ${local.name_prefix} event-driven architecture"
  deletion_window_in_days = var.kms_deletion_window
  enable_key_rotation     = true

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 2. S3 — event archive; DLQ replay storage; long-term retention
#    Outputs consumed by: (application code reads/writes directly)
# ═══════════════════════════════════════════════════════════════════════════════
module "s3" {
  source  = "sourcefuse/arc-s3/aws"
  version = "0.0.7"

  name = local.archive_bucket

  server_side_encryption_config_data = {
    bucket_key_enabled = true
    sse_algorithm      = "aws:kms"
    kms_master_key_id  = module.kms.key_arn
  }

  public_access_config = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 3. DynamoDB — event store; persists processed events for auditing + replay
#    Outputs consumed by: module.lambda (via environment variable at runtime)
# ═══════════════════════════════════════════════════════════════════════════════
module "dynamodb" {
  source  = "sourcefuse/arc-dynamodb/aws"
  version = "0.0.1"

  table_name   = local.table_name
  hash_key     = var.dynamodb_hash_key
  range_key    = var.dynamodb_range_key != "" ? var.dynamodb_range_key : null
  attributes   = local.dynamodb_attributes
  billing_mode = var.dynamodb_billing_mode

  server_side_encryption_enabled     = true
  server_side_encryption_kms_key_arn = module.kms.key_arn

  # HIPAA: enable point-in-time recovery for event auditability
  point_in_time_recovery_enabled = local.dynamodb_pitr_enabled
  deletion_protection_enabled    = local.is_strict

  # Enable DynamoDB Streams so consumers can react to stored events
  # stream_enabled   = true
  # stream_view_type = "NEW_AND_OLD_IMAGES"

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 4. SNS — fan-out event topic; producers publish here
#    Outputs consumed by: module.sqs (subscriptions wired via aws_sns_topic_subscription)
# ═══════════════════════════════════════════════════════════════════════════════
module "sns" {
  source  = "sourcefuse/arc-sns/aws"
  version = "0.0.4"

  name             = local.sns_topic_name
  kms_master_key_id = module.kms.key_id

  # Wire SQS queue as a subscriber after both SNS + SQS are created.
  # Use a separate aws_sns_topic_subscription resource or the subscriptions map:
  # subscriptions = {
  #   "event-processor" = {
  #     protocol = "sqs"
  #     endpoint = module.sqs.queue_arn
  #     raw_message_delivery = true
  #   }
  # }

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 5. SQS — event processing queue with built-in DLQ
#    Outputs consumed by: module.lambda (event source mapping)
# ═══════════════════════════════════════════════════════════════════════════════
module "sqs" {
  source  = "sourcefuse/arc-sqs/aws"
  version = "0.0.3"

  name = local.sqs_queue_name

  message_config = {
    visibility_timeout        = var.sqs_visibility_timeout
    retention_seconds         = var.sqs_message_retention_seconds
    receive_wait_time_seconds = 20  # long-polling reduces empty receives
  }

  # Encrypt queue with CMK
  kms_config = {
    key_arn               = module.kms.key_arn
    create_key            = false
    data_key_reuse_period = 300
  }

  # Built-in DLQ — failed messages land here after max_receive_count attempts
  dlq_config = {
    enabled           = true
    name              = "${local.sqs_queue_name}-dlq"
    max_receive_count = local.is_strict ? 1 : 3
    # HIPAA: single retry before DLQ ensures no duplicate processing of PHI
    message_retention_seconds = 1209600  # 14 days (max)
  }

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 6. Lambda — event consumer; triggered by SQS; writes to DynamoDB + S3
#    Add aws_lambda_event_source_mapping after apply to wire SQS → Lambda.
# ═══════════════════════════════════════════════════════════════════════════════
module "lambda" {
  source  = "sourcefuse/arc-lambda-function/aws"
  version = "0.0.2"

  function_name = local.function_name

  s3_bucket   = var.lambda_s3_bucket
  s3_key      = var.lambda_s3_key
  kms_key_arn = module.kms.key_arn

  runtime     = var.lambda_runtime
  handler     = var.lambda_handler
  memory_size = var.lambda_memory_size
  timeout     = var.lambda_timeout

  # HIPAA: cap concurrency to limit blast radius
  reserved_concurrent_executions = local.is_strict ? 50 : -1

  create_log_group      = true
  log_retention_in_days = local.log_retention_days

  # Wire event-store context into the function at runtime
  # environment_variables = {
  #   DYNAMODB_TABLE    = module.dynamodb.dynamodb_table_name
  #   ARCHIVE_BUCKET    = module.s3.bucket_id
  #   EVENT_REGION      = var.region
  # }

  tags = local.tags
}
