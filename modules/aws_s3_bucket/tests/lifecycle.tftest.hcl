mock_provider "aws" {}

variables {
  name = "bucket-de-teste"
}

run "regras_variadas" {
  command = plan

  variables {
    lifecycle_rules = [
      {
        id                                     = "bucket-inteiro"
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
        id      = "so-prefixo"
        enabled = false
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
        id = "so-tag"
        filter = {
          tags = { Temporario = "true" }
        }
        expiration = {
          days = 1
        }
      },
      {
        id = "combinado"
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
  }

  assert {
    condition     = length(aws_s3_bucket_lifecycle_configuration.this) == 1
    error_message = "Com regras, uma única configuração de lifecycle deve ser criada."
  }

  assert {
    condition     = length(aws_s3_bucket_lifecycle_configuration.this[0].rule) == 4
    error_message = "Todas as regras devem ser criadas."
  }

  # Regra sem critérios: filter vazio, vale para o bucket todo.
  # (filter.prefix é Computed no provider e fica desconhecido no plan quando não informado.)
  assert {
    condition = (
      length(aws_s3_bucket_lifecycle_configuration.this[0].rule[0].filter[0].tag) == 0 &&
      length(aws_s3_bucket_lifecycle_configuration.this[0].rule[0].filter[0].and) == 0
    )
    error_message = "Regra sem critérios deve ter filter vazio."
  }

  assert {
    condition     = aws_s3_bucket_lifecycle_configuration.this[0].rule[0].abort_incomplete_multipart_upload[0].days_after_initiation == 7
    error_message = "abort_incomplete_multipart_upload deve ser configurado."
  }

  assert {
    condition     = aws_s3_bucket_lifecycle_configuration.this[0].rule[0].noncurrent_version_expiration[0].newer_noncurrent_versions == 3
    error_message = "noncurrent_version_expiration deve ser configurado."
  }

  # Critério único: prefixo direto no filter.
  assert {
    condition = (
      aws_s3_bucket_lifecycle_configuration.this[0].rule[1].filter[0].prefix == "logs/" &&
      length(aws_s3_bucket_lifecycle_configuration.this[0].rule[1].filter[0].and) == 0
    )
    error_message = "Critério único de prefixo deve ir direto no filter."
  }

  assert {
    condition     = aws_s3_bucket_lifecycle_configuration.this[0].rule[1].status == "Disabled"
    error_message = "enabled = false deve virar status Disabled."
  }

  assert {
    condition     = length(aws_s3_bucket_lifecycle_configuration.this[0].rule[1].transition) == 2
    error_message = "As transições devem ser criadas."
  }

  # Critério único de tag: bloco tag direto no filter.
  assert {
    condition     = aws_s3_bucket_lifecycle_configuration.this[0].rule[2].filter[0].tag[0].key == "Temporario"
    error_message = "Critério único de tag deve usar o bloco tag."
  }

  # Vários critérios: tudo dentro de and.
  assert {
    condition = (
      length(aws_s3_bucket_lifecycle_configuration.this[0].rule[3].filter[0].tag) == 0 &&
      aws_s3_bucket_lifecycle_configuration.this[0].rule[3].filter[0].and[0].prefix == "tmp/" &&
      aws_s3_bucket_lifecycle_configuration.this[0].rule[3].filter[0].and[0].object_size_greater_than == 1048576 &&
      aws_s3_bucket_lifecycle_configuration.this[0].rule[3].filter[0].and[0].tags["Temporario"] == "true"
    )
    error_message = "Vários critérios devem ser combinados no bloco and."
  }
}
