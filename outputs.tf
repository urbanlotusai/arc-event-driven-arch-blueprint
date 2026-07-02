output "kms_key_arn" {
  description = "ARN of the KMS CMK used by SNS, SQS, DynamoDB, and Lambda."
  value       = module.kms.key_arn
}

output "kms_key_id" {
  description = "ID of the KMS CMK."
  value       = module.kms.key_id
}

output "sns_topic_arn" {
  description = "ARN of the SNS fan-out topic. Producers publish events here."
  value       = module.sns.topic_arn
}

output "sqs_queue_url" {
  description = "URL of the SQS event-processing queue."
  value       = module.sqs.queue_url
}

output "sqs_queue_arn" {
  description = "ARN of the SQS event-processing queue. Use in aws_lambda_event_source_mapping."
  value       = module.sqs.queue_arn
}

output "sqs_dlq_url" {
  description = "URL of the SQS dead-letter queue."
  value       = module.sqs.dead_letter_queue_url
}

output "sqs_dlq_arn" {
  description = "ARN of the SQS dead-letter queue."
  value       = module.sqs.dead_letter_queue_arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB event-store table."
  value       = module.dynamodb.dynamodb_table_name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB event-store table."
  value       = module.dynamodb.dynamodb_table_arn
}

output "lambda_function_arn" {
  description = "ARN of the Lambda event consumer function."
  value       = module.lambda.arn
}

output "lambda_role_arn" {
  description = "IAM execution role ARN for the Lambda consumer. Use to grant SQS/DynamoDB/S3 permissions."
  value       = module.lambda.role_arn
}

output "archive_bucket_id" {
  description = "S3 bucket name for event archive and DLQ replay storage."
  value       = module.s3.bucket_id
}
