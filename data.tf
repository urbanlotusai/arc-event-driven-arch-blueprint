# ── Account identity ──────────────────────────────────────────────────────────
data "aws_caller_identity" "current" {}

# ── KMS key policy ────────────────────────────────────────────────────────────
# Grants account root full control of the CMK.
# After first apply, scope this down to the Lambda execution role + SNS service.
data "aws_iam_policy_document" "kms" {
  statement {
    sid    = "AllowAccountRoot"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  # SNS requires kms:GenerateDataKey and kms:Decrypt to publish encrypted messages
  statement {
    sid    = "AllowSNS"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ]
    resources = ["*"]
  }
}
