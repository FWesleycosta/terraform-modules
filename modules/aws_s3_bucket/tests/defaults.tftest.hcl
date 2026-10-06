mock_provider "aws" {}

variables {
  name = "bucket-de-teste"
}

run "defaults_seguros" {
  command = plan

  assert {
    condition     = aws_s3_bucket.this.bucket == "bucket-de-teste"
    error_message = "O bucket deve usar exatamente o name informado."
  }

  assert {
    condition     = aws_s3_bucket.this.force_destroy == false
    error_message = "force_destroy deve ser false por padrão."
  }

  assert {
    condition = alltrue([
      aws_s3_bucket_public_access_block.this.block_public_acls,
      aws_s3_bucket_public_access_block.this.block_public_policy,
      aws_s3_bucket_public_access_block.this.ignore_public_acls,
      aws_s3_bucket_public_access_block.this.restrict_public_buckets,
    ])
    error_message = "Os quatro bloqueios de acesso público devem estar ligados."
  }

  assert {
    condition     = aws_s3_bucket_ownership_controls.this.rule[0].object_ownership == "BucketOwnerEnforced"
    error_message = "ACLs devem estar desativadas (BucketOwnerEnforced)."
  }

  assert {
    condition     = aws_s3_bucket_versioning.this.versioning_configuration[0].status == "Enabled"
    error_message = "O versionamento deve estar ligado por padrão."
  }

  assert {
    condition     = one([for r in aws_s3_bucket_server_side_encryption_configuration.this.rule : r.apply_server_side_encryption_by_default[0].sse_algorithm]) == "aws:kms"
    error_message = "A criptografia padrão deve ser aws:kms."
  }

  assert {
    condition     = one([for r in aws_s3_bucket_server_side_encryption_configuration.this.rule : r.bucket_key_enabled]) == true
    error_message = "O S3 Bucket Key deve estar ligado por padrão com KMS."
  }

  assert {
    condition     = toset(one([for r in aws_s3_bucket_server_side_encryption_configuration.this.rule : r.blocked_encryption_types])) == toset(["SSE-C"])
    error_message = "SSE-C deve estar bloqueado."
  }

  assert {
    condition     = toset([for s in data.aws_iam_policy_document.this.statement : s.sid]) == toset(["DenyInsecureTransport", "DenyOutdatedTls"])
    error_message = "A policy deve negar acesso sem TLS e com TLS anterior a 1.2."
  }

  assert {
    condition     = length(aws_s3_bucket_lifecycle_configuration.this) == 0
    error_message = "Sem regras, nenhuma configuração de lifecycle deve ser criada."
  }

  assert {
    condition     = length(aws_s3_bucket.this.tags) == 0
    error_message = "Sem tags informadas, o bucket não deve ter tags do módulo."
  }
}
