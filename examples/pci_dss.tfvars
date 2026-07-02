# ── Profile: pci_dss ──────────────────────────────────────────────────────────
# Activates the PCI DSS overlay:
#   - DynamoDB PITR + deletion_protection = true
#   - Lambda concurrency cap = 25 (tighter than HIPAA's 50)
#   - SQS DLQ max retries = 1
#   - Log retention 365 days

environment = "prod"
namespace   = "myorg"

compliance_profile = "pci_dss"

lambda_s3_bucket = "myorg-lambda-artifacts"
lambda_s3_key    = "consumers/handler-v1.0.0.zip"
