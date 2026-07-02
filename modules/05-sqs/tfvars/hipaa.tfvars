# =============================================================================
# 05-sqs - HIPAA Compliance Profile
# =============================================================================
# Compliance controls enabled:
#   - max_receive_count = 1 — a single failed delivery attempt moves the
#     message straight to the DLQ instead of retrying, which avoids
#     duplicate processing of PHI-bearing events by a flaky consumer.
# =============================================================================

dlq_max_receive_count = 1
