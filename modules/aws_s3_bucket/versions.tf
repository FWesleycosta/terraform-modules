terraform {
  required_version = ">= 1.11"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      # 6.22 trouxe rule.blocked_encryption_types; 6.40 corrigiu diffs perpétuos
      # nesse argumento e em kms_master_key_id/bucket_key_enabled.
      version = ">= 6.40"
    }
  }
}
