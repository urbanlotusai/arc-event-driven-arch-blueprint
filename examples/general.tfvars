# ── Profile: general ──────────────────────────────────────────────────────────
# Sensible production defaults. KMS rotation on, no extra compliance constraints.

environment      = "prod"
namespace        = "myorg"
lambda_s3_bucket = "myorg-lambda-artifacts"
lambda_s3_key    = "consumers/handler-v1.0.0.zip"

compliance_profile = "general"
