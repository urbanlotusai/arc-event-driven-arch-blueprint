# ── Profile: hipaa ────────────────────────────────────────────────────────────
# Activates the HIPAA overlay: DynamoDB PITR + deletion protection,
# Lambda concurrency capped to 50, SQS DLQ retries = 1, 365-day log retention.

environment      = "prod"
namespace        = "myorg"
lambda_s3_bucket = "myorg-lambda-artifacts"
lambda_s3_key    = "consumers/handler-v1.0.0.zip"

compliance_profile = "hipaa"
