<div align="center">

# ARC Event-Driven Architecture Blueprint

### Production-grade async event processing on AWS — in one `terraform apply`

**A SourceFuse ARC Blueprint**

![Version](https://img.shields.io/badge/version-1.0.0-E8392A)
![License](https://img.shields.io/badge/license-Apache--2.0-1A1A2E)
![Terraform](https://img.shields.io/badge/terraform-%3E%3D1.3-7B42BC)
![AWS Provider](https://img.shields.io/badge/aws--provider-%3E%3D5.0-FF9900)
![ARC Modules](https://img.shields.io/badge/ARC%20modules-6-E8392A)

</div>

---

## What is this?

A **ready-to-deploy Terraform blueprint** that wires a complete, production-grade event-driven
architecture on AWS by composing **6 battle-tested [SourceFuse ARC](https://registry.terraform.io/namespaces/modules/sourcefuse)
modules**. One `terraform apply` gives you:

- An **SNS topic** for fan-out event publishing
- An **SQS queue** (+ built-in DLQ) for reliable async processing
- A **Lambda consumer** triggered by SQS
- A **DynamoDB event store** for persistence and replay
- An **S3 archive bucket** for DLQ replay and long-term storage
- A single **KMS CMK** encrypting everything end-to-end

No hand-wiring of IAM, KMS grants, SQS redrive policies, or Lambda triggers. The hard parts are already solved.

---

## Architecture

```
  Producer (any service)
       │
       ▼
  SNS Topic  ──── (fan-out to multiple subscribers)
       │
       ▼
  SQS Queue  (visibility timeout = 6× Lambda timeout)
       │                    │
       │   max_receive_count retries    │
       ▼                    ▼
  Lambda Consumer        SQS DLQ
       │                    │
       ├──► DynamoDB         └──► S3 Archive (replay)
       │    (event store,
       │     KMS encrypted)
       └──► S3 Archive
            (successful events,
             long-term retention)

  └── KMS CMK ─── SNS · SQS · DynamoDB · Lambda env vars · S3
```

---

## The 6 ARC modules

| Module | Version | Role |
|---|---|---|
| [arc-kms](https://registry.terraform.io/modules/sourcefuse/arc-kms/aws) | 1.0.11 | Customer Managed Key — root of the encryption trust chain |
| [arc-s3](https://registry.terraform.io/modules/sourcefuse/arc-s3/aws) | 0.0.7 | Event archive and DLQ replay storage (encrypted, private) |
| [arc-dynamodb](https://registry.terraform.io/modules/sourcefuse/arc-dynamodb/aws) | 0.0.1 | Event store with optional PITR |
| [arc-sns](https://registry.terraform.io/modules/sourcefuse/arc-sns/aws) | 0.0.4 | Fan-out event topic (KMS-encrypted) |
| [arc-sqs](https://registry.terraform.io/modules/sourcefuse/arc-sqs/aws) | 0.0.3 | Processing queue with built-in DLQ |
| [arc-lambda-function](https://registry.terraform.io/modules/sourcefuse/arc-lambda-function/aws) | 0.0.2 | Event consumer triggered by SQS |

---

## Quick start

### 1. Prerequisites

- **Terraform** `>= 1.3` ([install guide](docs/INSTALL.md))
- **AWS account + credentials** (`aws configure`)
- **An S3 bucket** for Lambda deployment packages (create once, reuse)
- **A Lambda deployment zip** uploaded to that bucket

### 2. Configure

```bash
git clone https://github.com/sourcefuse/arc-event-driven-arch-blueprint.git
cd arc-event-driven-arch-blueprint

cp examples/general.tfvars terraform.tfvars
```

Edit the four mandatory values in `terraform.tfvars`:

| Variable | Example |
|---|---|
| `environment` | `prod` |
| `namespace` | `myorg` |
| `lambda_s3_bucket` | `myorg-lambda-artifacts` |
| `lambda_s3_key` | `consumers/handler-v1.0.0.zip` |

### 3. Deploy

| Step | With `make` | Raw Terraform |
|---|---|---|
| Validate | `make validate` | `terraform init -backend=false && terraform validate` |
| Preview | `make plan` | `terraform plan` |
| Deploy | `make apply` | `terraform init && terraform apply` |

### 4. Wire SQS → Lambda

After `apply`, create the event source mapping to trigger the consumer:

```bash
aws lambda create-event-source-mapping \
  --function-name $(terraform output -raw lambda_function_arn) \
  --event-source-arn $(terraform output -raw sqs_queue_arn) \
  --batch-size 10 \
  --starting-position LATEST
```

Or add it as a `aws_lambda_event_source_mapping` resource in a `post-apply.tf` file.

### 5. Subscribe SQS to SNS

```bash
aws sns subscribe \
  --topic-arn $(terraform output -raw sns_topic_arn) \
  --protocol sqs \
  --notification-endpoint $(terraform output -raw sqs_queue_arn)
```

---

## Compliance profiles

| Profile | Effect |
|---|---|
| `general` | KMS rotation on, 90-day log retention, 3-retry DLQ |
| `hipaa` | DynamoDB PITR + deletion protection, Lambda concurrency cap (50), 1-retry DLQ, 365-day log retention |
| `pci_dss` | DynamoDB PITR + deletion protection, Lambda concurrency cap (25), 1-retry DLQ, 365-day log retention |

---

## Key outputs

```bash
terraform output sns_topic_arn         # publish events here
terraform output sqs_queue_url         # poll / inspect here
terraform output sqs_dlq_url           # monitor failed events
terraform output dynamodb_table_name   # event store
terraform output lambda_function_arn   # consumer function
terraform output lambda_role_arn       # grant additional permissions here
terraform output archive_bucket_id     # S3 archive
terraform output kms_key_arn           # CMK
```

---

## Why use this blueprint?

| Advantage | What it means for you |
|---|---|
| **Minutes, not days** | A secured event pipeline normally requiring days of IAM/SQS/DLQ wiring deploys with four inputs and one command. |
| **Secure by default** | Single KMS CMK encrypts SNS, SQS, DynamoDB, Lambda env vars, and S3. No plaintext data at rest. |
| **Compliance-ready** | Built-in `general` / `hipaa` / `pci_dss` profiles flip on DynamoDB PITR, Lambda concurrency caps, tighter DLQ retries, and 365-day log retention — no manual edits. |
| **Proven building blocks** | Every resource comes from a published, versioned SourceFuse ARC module. Upgrades are a version bump, not a rewrite. |
| **Failure-safe** | DLQ + S3 archive ensure no event is silently dropped. Dead events are inspectable and replayable. |
| **Portable & auditable** | Pure Terraform. Version-controlled, reproducible across environments and accounts. |

---

## Project structure

```
arc-event-driven-arch-blueprint/
├── main.tf                   # 6 ARC module blocks, in dependency order
├── variables.tf              # all inputs with types & descriptions
├── locals.tf                 # naming, tags, compliance overlays
├── data.tf                   # caller identity, KMS policy
├── outputs.tf                # topic/queue/table/function ARNs
├── version.tf                # Terraform + AWS provider pins
├── .terraform-version        # tfenv pin (1.9.8)
├── terraform.tfvars.example  # copy to terraform.tfvars
├── modules/                  # one numbered wrapper per ARC module
│   ├── 01-kms/
│   ├── 02-s3/
│   ├── 03-dynamodb/
│   ├── 04-sns/
│   ├── 05-sqs/
│   └── 06-lambda/
├── sample-app/                # publisher script proving the pipeline end-to-end
├── examples/                 # ready-to-use tfvars per compliance profile
│   ├── general.tfvars
│   ├── hipaa.tfvars
│   └── pci_dss.tfvars
├── docs/
│   ├── INSTALL.md            # macOS · Linux · Windows setup guide
│   └── DEPLOYMENT.md        # full deployment reference + rollback
├── GETTING-STARTED.md        # beginner walkthrough
├── CONTRIBUTING.md
├── CHANGELOG.md · LICENSE · NOTICE · Makefile · VERSION
└── README.md
```

---

## Documentation

- **[GETTING-STARTED.md](GETTING-STARTED.md)** — zero-to-live walkthrough for first-timers
- **[docs/INSTALL.md](docs/INSTALL.md)** — install Terraform & AWS CLI on macOS / Linux / Windows
- **[docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)** — full deployment reference, post-apply steps, rollback
- **[examples/README.md](examples/README.md)** — compliance-profile example files

---

## Important notes

- **Events are not automatically flowing after `apply`** — wire the SQS event source mapping to Lambda manually or via `aws_lambda_event_source_mapping` (see Step 4 in Quick start above).
- **DLQ monitoring** — set a CloudWatch alarm on `ApproximateNumberOfMessagesNotVisible` on the DLQ; silent failures here mean lost events.
- **Two-apply KMS pattern** — the Lambda execution role doesn't exist until after the first apply. Narrow the KMS key policy to least-privilege afterward (see [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)).

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

Apache License 2.0 — see [LICENSE](LICENSE) and [NOTICE](NOTICE).

---

<div align="center">

### Built by [SourceFuse](https://www.sourcefuse.com)

Part of the **ARC** (Accelerated Reference Cloud) blueprint family.
Explore all ARC modules on the [Terraform Registry](https://registry.terraform.io/namespaces/modules/sourcefuse).

</div>
