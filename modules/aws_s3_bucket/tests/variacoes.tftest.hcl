mock_provider "aws" {}

variables {
  name = "bucket-de-teste"
}

run "aes256" {
  command = plan

  variables {
    encryption = {
      sse_algorithm = "AES256"
    }
  }

  assert {
    condition     = one([for r in aws_s3_bucket_server_side_encryption_configuration.this.rule : r.apply_server_side_encryption_by_default[0].sse_algorithm]) == "AES256"
    error_message = "O algoritmo deve ser AES256."
  }

  assert {
    condition     = toset(one([for r in aws_s3_bucket_server_side_encryption_configuration.this.rule : r.blocked_encryption_types])) == toset(["SSE-C"])
    error_message = "SSE-C deve continuar bloqueado com AES256."
  }
}

run "kms_gerenciada_pelo_cliente" {
  command = plan

  variables {
    encryption = {
      sse_algorithm      = "aws:kms"
      kms_key_arn        = "arn:aws:kms:us-east-1:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"
      bucket_key_enabled = false
    }
  }

  assert {
    condition     = one([for r in aws_s3_bucket_server_side_encryption_configuration.this.rule : r.apply_server_side_encryption_by_default[0].kms_master_key_id]) == "arn:aws:kms:us-east-1:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"
    error_message = "A chave KMS informada deve ser usada."
  }

  assert {
    condition     = one([for r in aws_s3_bucket_server_side_encryption_configuration.this.rule : r.bucket_key_enabled]) == false
    error_message = "bucket_key_enabled deve respeitar o valor informado."
  }
}

run "versionamento_suspenso" {
  command = plan

  variables {
    versioning_enabled = false
  }

  # O aviso do check "versionamento" é esperado aqui.
  expect_failures = [check.versionamento]

  assert {
    condition     = aws_s3_bucket_versioning.this.versioning_configuration[0].status == "Suspended"
    error_message = "Com versioning_enabled = false o status deve ser Suspended."
  }
}

run "force_destroy" {
  command = plan

  variables {
    force_destroy = true
  }

  # O aviso do check "force_destroy" é esperado aqui.
  expect_failures = [check.force_destroy]

  assert {
    condition     = aws_s3_bucket.this.force_destroy == true
    error_message = "force_destroy deve respeitar o opt-in."
  }
}

run "policy_adicional" {
  command = plan

  variables {
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Sid       = "LeituraPelaConta"
        Effect    = "Allow"
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::bucket-de-teste/*"
        Principal = { AWS = "arn:aws:iam::111122223333:root" }
      }]
    })
  }

  assert {
    condition     = length(data.aws_iam_policy_document.this.source_policy_documents) == 1
    error_message = "A policy adicional deve ser mesclada ao documento do módulo."
  }

  assert {
    condition     = length(data.aws_iam_policy_document.this.statement) == 2
    error_message = "Os statements de TLS do módulo devem continuar presentes."
  }
}

run "tags" {
  command = plan

  variables {
    tags = {
      Environment = "teste"
      Owner       = "plataforma"
    }
  }

  assert {
    condition     = aws_s3_bucket.this.tags == tomap({ Environment = "teste", Owner = "plataforma" })
    error_message = "As tags devem ser aplicadas ao bucket."
  }
}
