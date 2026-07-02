output "dynamodb_table_name" {
  description = "Name of the DynamoDB event-store table."
  value       = module.dynamodb.dynamodb_table_name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB event-store table."
  value       = module.dynamodb.dynamodb_table_arn
}
