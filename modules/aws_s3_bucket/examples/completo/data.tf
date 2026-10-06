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
      identifiers = [local.account_root_arn]
    }
  }
}

data "aws_iam_policy_document" "leitura" {
  statement {
    sid       = "LeituraPelaConta"
    actions   = ["s3:GetObject"]
    resources = ["${local.bucket_arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [local.account_root_arn]
    }
  }
}
