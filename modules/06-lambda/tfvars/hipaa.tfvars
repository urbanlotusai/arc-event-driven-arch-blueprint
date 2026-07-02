# =============================================================================
# 06-lambda - HIPAA Compliance Profile
# =============================================================================
# Compliance controls enabled:
#   - reserved_concurrent_executions = 50 — caps blast radius of a runaway
#     invocation loop that could otherwise process/expose PHI at scale.
#   - log_retention_in_days = 365 — supports HIPAA's 6-year record-retention
#     expectation (45 CFR 164.316(b)(2)(i)) at the CloudWatch hot-tier layer;
#     archive to S3/Glacier for the full 6-year window.
# =============================================================================

reserved_concurrent_executions = 50
log_retention_in_days          = 365
