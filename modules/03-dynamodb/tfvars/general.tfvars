# =============================================================================
# 03-dynamodb - General Compliance Profile
# =============================================================================
# Standard event-store table. PITR and deletion protection are off to keep
# dev/test costs and friction low; encryption is still always on via the CMK
# from 01-kms regardless of profile.
# =============================================================================

point_in_time_recovery_enabled = false
deletion_protection_enabled    = false
