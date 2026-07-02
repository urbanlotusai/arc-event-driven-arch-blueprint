# Deployment Reference

Full reference for deploying, operating, and tearing down the ARC Event-Driven Architecture Blueprint.

---

## Prerequisites

- Terraform `>= 1.3` ([INSTALL.md](INSTALL.md))
- AWS credentials configured (`aws configure`)
- An S3 bucket for Lambda deployment packages
- A Lambda consumer zip uploaded to that bucket

---

## Deploy

```bash
cp examples/general.tfvars terraform.tfvars   # or hipaa.tfvars
terraform init
terraform plan
terraform apply
```

---

## Post-apply wiring

### 1. Create the SQS → Lambda event source mapping

```bash
aws lambda create-event-source-mapping \
  --function-name $(terraform output -raw lambda_function_arn) \
  --event-source-arn $(terraform output -raw sqs_queue_arn) \
  --batch-size 10 \
  --function-response-types ReportBatchItemFailures
```

`ReportBatchItemFailures` lets Lambda report individual message failures so only failed items go to the DLQ.

### 2. Subscribe SQS queue to the SNS topic

```bash
aws sns subscribe \
  --topic-arn $(terraform output -raw sns_topic_arn) \
  --protocol sqs \
  --notification-endpoint $(terraform output -raw sqs_queue_arn)
```

Then add a resource-based policy on the SQS queue allowing SNS to send messages:

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Service": "sns.amazonaws.com" },
    "Action": "sqs:SendMessage",
    "Resource": "<sqs_queue_arn>",
    "Condition": { "ArnEquals": { "aws:SourceArn": "<sns_topic_arn>" } }
  }]
}
```

### 3. KMS least-privilege (after first apply)

The initial KMS policy grants account root + SNS service access. After apply, scope it down:

```hcl
# Add to data.tf after first apply:
statement {
  sid = "AllowLambdaConsumer"
  principals {
    type        = "AWS"
    identifiers = [module.lambda.role_arn]
  }
  actions   = ["kms:GenerateDataKey", "kms:Decrypt"]
  resources = ["*"]
}
```

---

## Monitor DLQ

```bash
aws sqs get-queue-attributes \
  --queue-url $(terraform output -raw sqs_dlq_url) \
  --attribute-names ApproximateNumberOfMessages
```

Replay DLQ messages by moving them back to the main queue (or reprocess from S3 archive).

---

## Tear down

```bash
terraform destroy
```

Note: S3 and DynamoDB have `deletion_protection_enabled = true` under the `hipaa` profile. Disable them first:

```bash
terraform apply -var='compliance_profile=general'
terraform destroy
```
