# Examples

Ready-made `terraform.tfvars` files for each compliance profile.

| File | Profile | Description |
|---|---|---|
| `general.tfvars` | `general` | Sensible production defaults |
| `hipaa.tfvars` | `hipaa` | PITR on DynamoDB, concurrency caps, 365-day logs |

Copy the file that matches your environment to `../terraform.tfvars` before running `terraform plan`.
