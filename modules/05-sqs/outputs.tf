output "queue_url" {
  description = "URL of the SQS event-processing queue."
  value       = module.sqs.queue_url
}

output "queue_arn" {
  description = "ARN of the SQS event-processing queue. Use in aws_lambda_event_source_mapping."
  value       = module.sqs.queue_arn
}

output "dead_letter_queue_url" {
  description = "URL of the SQS dead-letter queue."
  value       = module.sqs.dead_letter_queue_url
}

output "dead_letter_queue_arn" {
  description = "ARN of the SQS dead-letter queue."
  value       = module.sqs.dead_letter_queue_arn
}
