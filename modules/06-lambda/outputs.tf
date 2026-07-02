output "arn" {
  description = "ARN of the Lambda event consumer function."
  value       = module.lambda.arn
}

output "role_arn" {
  description = "IAM execution role ARN for the Lambda consumer. Use to grant SQS/DynamoDB/S3 permissions."
  value       = module.lambda.role_arn
}
