# Sample App

Two zero-dependency-beyond-the-AWS-SDK pieces proving the SNS → SQS → Lambda → DynamoDB/S3 pipeline works end-to-end.

```
publish.js → SNS topic → SQS queue → Lambda (handler.js) → DynamoDB + S3 archive
```

---

## handler.js — the Lambda deployment package

`var.lambda_s3_bucket` / `var.lambda_s3_key` must point to a zipped copy of `handler.js` **before** `terraform apply` (the Lambda module deploys from S3, not inline code).

```bash
cd sample-app
zip function.zip handler.js
aws s3 cp function.zip s3://<your-deployment-bucket>/event-driven-arch/function.zip

# Then in terraform.tfvars:
# lambda_s3_bucket = "<your-deployment-bucket>"
# lambda_s3_key    = "event-driven-arch/function.zip"
# lambda_handler   = "handler.handler"
# lambda_runtime   = "nodejs20.x"
```

## publish.js — end-to-end event publisher

```bash
cd sample-app
npm install
SNS_TOPIC_ARN=$(terraform output -raw sns_topic_arn) \
AWS_REGION=<your-region> \
node publish.js
```

## Verify the pipeline

```bash
# Confirm the event landed in DynamoDB
aws dynamodb scan --table-name $(terraform output -raw dynamodb_table_name) --max-items 5

# Confirm Lambda logs show it was processed
aws logs tail /aws/lambda/$(terraform output -raw lambda_function_arn | awk -F: '{print $NF}') --follow

# Confirm the DLQ is empty (no failed messages)
aws sqs get-queue-attributes --queue-url $(terraform output -raw sqs_dlq_url) --attribute-names ApproximateNumberOfMessages
```

## Order of operations

1. Zip and upload `handler.js` to an S3 deployment bucket
2. Set `lambda_s3_bucket` / `lambda_s3_key` in `terraform.tfvars`
3. `terraform apply` — creates KMS, S3 archive, DynamoDB, SNS, SQS, Lambda
4. Wire the SNS → SQS subscription and SQS → Lambda event source mapping (see commented blocks in `main.tf`)
5. Run `publish.js` and confirm the event reaches DynamoDB

---

Built by **[SourceFuse](https://www.sourcefuse.com)**.
