# Changelog

All notable changes to the **ARC Event-Driven Architecture Blueprint** are documented here.
This project adheres to [Semantic Versioning](https://semver.org/).

## [1.0.0] — 2026-07-02

Initial public release. A standalone, deployable Terraform configuration that composes
**6 SourceFuse ARC modules** into a production-grade event-driven architecture on AWS.

### Modules

| Module | Version | Role |
|---|---|---|
| `sourcefuse/arc-kms/aws` | 1.0.11 | Customer Managed Key — root of the encryption trust chain |
| `sourcefuse/arc-s3/aws` | 0.0.7 | Event archive and DLQ replay storage |
| `sourcefuse/arc-dynamodb/aws` | 0.0.1 | Event store (KMS SSE, optional PITR) |
| `sourcefuse/arc-sns/aws` | 0.0.4 | Fan-out event topic (KMS-encrypted) |
| `sourcefuse/arc-sqs/aws` | 0.0.3 | Processing queue with built-in DLQ |
| `sourcefuse/arc-lambda-function/aws` | 0.0.2 | Event consumer triggered by SQS |

### Features

- SNS fan-out → SQS → Lambda consumer → DynamoDB event store, all encrypted by a single KMS CMK
- Built-in DLQ on SQS with configurable `max_receive_count`
- Compliance overlay via `compliance_profile` (`general` | `hipaa`)
- Example `terraform.tfvars` per compliance profile under `examples/`

[1.0.0]: https://github.com/sourcefuse/arc-event-driven-arch-blueprint
