module "sns" {
  source  = "sourcefuse/arc-sns/aws"
  version = "0.0.4"

  name              = var.name
  kms_master_key_id = var.kms_master_key_id

  tags = var.tags
}
