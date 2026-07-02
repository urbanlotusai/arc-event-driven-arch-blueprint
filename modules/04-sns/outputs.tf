output "topic_arn" {
  description = "ARN of the SNS fan-out topic. Producers publish events here."
  value       = module.sns.topic_arn
}
