# =============================================================================
# 03-dynamodb - HIPAA Compliance Profile
# =============================================================================
# Compliance controls enabled:
#   - Point-in-time recovery — supports the HIPAA Security Rule's data
#     backup/disaster-recovery requirements (45 CFR 164.308(a)(7)) for PHI
#     stored in the event store.
#   - Deletion protection — guards against accidental loss of PHI audit
#     records that must be retrievable for the required retention period.
# =============================================================================

point_in_time_recovery_enabled = true
deletion_protection_enabled    = true
