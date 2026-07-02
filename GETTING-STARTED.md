# Getting Started — A Beginner's Walkthrough

> Never used Terraform or AWS before? This guide takes you from nothing to a running
> event-driven architecture. Works on **macOS, Linux, and Windows**.

---

## Phase A — Set up your computer (one time)

Install the three required tools. Full per-OS instructions are in **[docs/INSTALL.md](docs/INSTALL.md)**:

| Tool | Quick install (macOS) |
|---|---|
| **Git** | `brew install git` |
| **Terraform** | `brew install tfenv && tfenv install` |
| **AWS CLI** | `brew install awscli` |

Configure AWS credentials:

```bash
aws configure
# AWS Access Key ID:     <from IAM>
# AWS Secret Access Key: <from IAM>
# Default region name:   us-east-1
```

---

## Phase B — Prerequisites

### 1. An S3 bucket for Lambda packages

```bash
aws s3 mb s3://myorg-lambda-artifacts --region us-east-1
```

### 2. Upload your consumer Lambda zip

```bash
aws s3 cp your-consumer.zip s3://myorg-lambda-artifacts/consumers/handler-v1.0.0.zip
```

> No consumer code yet? Use a placeholder zip with a simple `index.js`:
> ```js
> exports.handler = async (event) => { console.log(JSON.stringify(event)); };
> ```

---

## Phase C — Deploy

### 3. Clone and configure

```bash
git clone https://github.com/sourcefuse/arc-event-driven-arch-blueprint.git
cd arc-event-driven-arch-blueprint

cp examples/general.tfvars terraform.tfvars
```

Edit the four mandatory values in `terraform.tfvars`.

### 4. Deploy

```bash
terraform init
terraform plan    # dry-run — nothing is built yet
terraform apply   # type "yes" to deploy
```

### 5. Connect the pieces

After apply, wire SQS as a Lambda trigger:

```bash
aws lambda create-event-source-mapping \
  --function-name $(terraform output -raw lambda_function_arn) \
  --event-source-arn $(terraform output -raw sqs_queue_arn) \
  --batch-size 10 \
  --starting-position LATEST
```

Subscribe the SQS queue to the SNS topic:

```bash
aws sns subscribe \
  --topic-arn $(terraform output -raw sns_topic_arn) \
  --protocol sqs \
  --notification-endpoint $(terraform output -raw sqs_queue_arn)
```

### 6. Test it

Publish a test event to SNS:

```bash
aws sns publish \
  --topic-arn $(terraform output -raw sns_topic_arn) \
  --message '{"event":"test","data":"hello"}'
```

Check Lambda logs:

```bash
aws logs tail /aws/lambda/$(terraform output -raw lambda_function_arn | cut -d: -f7) --follow
```

---

## Tear down

```bash
terraform destroy
```

---

Built by **[SourceFuse](https://www.sourcefuse.com)** · Part of the ARC blueprint family.
