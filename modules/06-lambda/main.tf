module "lambda" {
  source  = "sourcefuse/arc-lambda-function/aws"
  version = "0.0.2"

  function_name = var.function_name

  s3_bucket   = var.s3_bucket
  s3_key      = var.s3_key
  kms_key_arn = var.kms_key_arn

  runtime     = var.runtime
  handler     = var.handler
  memory_size = var.memory_size
  timeout     = var.timeout

  reserved_concurrent_executions = var.reserved_concurrent_executions

  create_log_group      = true
  log_retention_in_days = var.log_retention_in_days

  tags = var.tags
}
