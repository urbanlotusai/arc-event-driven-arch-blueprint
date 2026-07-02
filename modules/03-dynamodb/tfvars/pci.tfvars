# =============================================================================
# 03-dynamodb - PCI-DSS Compliance Profile
# =============================================================================
# Compliance controls enabled:
#   - Point-in-time recovery — supports PCI DSS Req 12.10.1 (data recovery as
#     part of an incident response plan) for cardholder-data-adjacent events.
#   - Deletion protection — prevents accidental loss of records needed for
#     PCI DSS Req 10 audit trails.
# =============================================================================

point_in_time_recovery_enabled = true
deletion_protection_enabled    = true
