# Bucket com chave KMS gerenciada pelo cliente, policy adicional e regras de lifecycle.

provider "aws" {}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_iam_policy_document" "kms" {
  # Em policy de chave KMS, "*" em resources significa a própria chave.
  statement {
    sid       = "AdministracaoPelaConta"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

resource "aws_kms_key" "this" {
  description             = "Chave do bucket de exemplo do módulo aws_s3_bucket"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  policy                  = data.aws_iam_policy_document.kms.json
}

data "aws_iam_policy_document" "leitura" {
  statement {
    sid     = "LeituraPelaConta"
    actions = ["s3:GetObject"]
    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::exemplo-completo-aws-s3-bucket/*",
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

module "aws_s3_bucket" {
  source = "../.."

  name = "exemplo-completo-aws-s3-bucket"

  encryption = {
    sse_algorithm = "aws:kms"
    kms_key_arn   = aws_kms_key.this.arn
  }

  policy = data.aws_iam_policy_document.leitura.json

  lifecycle_rules = [
    {
      id                                     = "limpeza-geral"
      abort_incomplete_multipart_upload_days = 7
      expiration = {
        expired_object_delete_marker = true
      }
      noncurrent_version_transitions = [
        { noncurrent_days = 30, storage_class = "STANDARD_IA" },
      ]
      noncurrent_version_expiration = {
        noncurrent_days           = 90
        newer_noncurrent_versions = 3
      }
    },
    {
      id = "logs-arquivamento"
      filter = {
        prefix = "logs/"
      }
      transitions = [
        { days = 30, storage_class = "STANDARD_IA" },
        { days = 90, storage_class = "GLACIER_IR" },
      ]
      expiration = {
        days = 365
      }
    },
    {
      id = "temporarios-grandes"
      filter = {
        prefix                   = "tmp/"
        tags                     = { Temporario = "true" }
        object_size_greater_than = 1048576
      }
      expiration = {
        days = 7
      }
    },
  ]

  tags = {
    Environment = "exemplo"
  }
}

output "bucket_arn" {
  description = "ARN do bucket criado."
  value       = module.aws_s3_bucket.arn
}

output "kms_key_arn" {
  description = "ARN da chave KMS usada no bucket."
  value       = module.aws_s3_bucket.kms_key_arn
}
