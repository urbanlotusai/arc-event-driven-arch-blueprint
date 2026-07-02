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
  is_hipaa   = var.compliance_profile == "hipaa"
  is_pci_dss = var.compliance_profile == "pci_dss"
  is_strict  = local.is_hipaa || local.is_pci_dss

  dynamodb_pitr_enabled = local.is_strict
  log_retention_days    = local.is_strict ? 365 : 90

  # ── DynamoDB attribute definitions ────────────────────────────────────────────
  dynamodb_attributes = concat(
    [{ name = var.dynamodb_hash_key, type = "S" }],
    var.dynamodb_range_key != "" ? [{ name = var.dynamodb_range_key, type = "S" }] : []
  )
}
