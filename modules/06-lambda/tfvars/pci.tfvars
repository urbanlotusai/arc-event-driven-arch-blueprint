# =============================================================================
# 06-lambda - PCI-DSS Compliance Profile
# =============================================================================
# Compliance controls enabled:
#   - reserved_concurrent_executions = 50 — limits blast radius, consistent
#     with PCI DSS Req 1 network/resource segmentation principles.
#   - log_retention_in_days = 365 — supports PCI DSS v4.0 Req 10.5.1
#     (audit logs retained for at least 12 months).
# =============================================================================

reserved_concurrent_executions = 50
log_retention_in_days          = 365
