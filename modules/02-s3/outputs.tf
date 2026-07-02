output "bucket_id" {
  description = "S3 bucket name for event archive and DLQ replay storage."
  value       = module.s3.bucket_id
}

output "bucket_arn" {
  description = "S3 bucket ARN for event archive and DLQ replay storage."
  value       = module.s3.bucket_arn
}
