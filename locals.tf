locals {
  # ── Naming ────────────────────────────────────────────────────────────────────
  name_prefix    = "${var.namespace}-${var.environment}"
  kms_alias      = "alias/${local.name_prefix}-events"
  table_name     = "${local.name_prefix}-event-store"
  archive_bucket = "${local.name_prefix}-event-archive"
  sns_topic_name = "${local.name_prefix}-events"
  sqs_queue_name = "${local.name_prefix}-event-processor"
  function_name  = "${local.name_prefix}-event-consumer"

  # ── Tagging ───────────────────────────────────────────────────────────────────
  tags = {
    Environment       = var.environment
    Namespace         = var.namespace
    ManagedBy         = "terraform"
    Application       = "event-driven-arch"
    ComplianceProfile = var.compliance_profile
  }

  # ── Compliance flags ──────────────────────────────────────────────────────────
  is_strict = var.compliance_profile == "hipaa"

  # HIPAA: force point-in-time recovery on DynamoDB
  dynamodb_pitr_enabled = local.is_strict

  # HIPAA: CloudWatch log retention (365 days vs 90 days)
  log_retention_days = local.is_strict ? 365 : 90

  # ── DynamoDB attribute definitions ────────────────────────────────────────────
  dynamodb_attributes = concat(
    [{ name = var.dynamodb_hash_key, type = "S" }],
    var.dynamodb_range_key != "" ? [{ name = var.dynamodb_range_key, type = "S" }] : []
  )
}
