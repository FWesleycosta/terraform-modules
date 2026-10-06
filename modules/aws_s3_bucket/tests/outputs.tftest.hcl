mock_provider "aws" {}

variables {
  name = "bucket-de-teste"
}

override_resource {
  target = aws_s3_bucket.this
  values = {
    id                          = "bucket-de-teste"
    arn                         = "arn:aws:s3:::bucket-de-teste"
    bucket_region               = "us-east-1"
    bucket_regional_domain_name = "bucket-de-teste.s3.us-east-1.amazonaws.com"
  }
}

# O mock gera uma string aleatória para json; o aws_s3_bucket_policy exige JSON válido no apply.
override_data {
  target = data.aws_iam_policy_document.this
  values = {
    json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
  }
}

run "outputs_padrao" {
  command = apply

  assert {
    condition     = output.id == "bucket-de-teste"
    error_message = "output.id deve ser o nome do bucket."
  }

  assert {
    condition     = output.arn == "arn:aws:s3:::bucket-de-teste"
    error_message = "output.arn deve ser o ARN do bucket."
  }

  assert {
    condition     = output.region == "us-east-1"
    error_message = "output.region deve vir de bucket_region."
  }

  assert {
    condition     = output.bucket_regional_domain_name == "bucket-de-teste.s3.us-east-1.amazonaws.com"
    error_message = "output.bucket_regional_domain_name deve vir do bucket."
  }

  assert {
    condition     = output.versioning_status == "Enabled"
    error_message = "output.versioning_status deve ser Enabled por padrão."
  }

  assert {
    condition     = output.kms_key_arn == null
    error_message = "Sem chave do cliente, output.kms_key_arn deve ser null."
  }
}

run "outputs_com_kms" {
  command = apply

  variables {
    versioning_enabled = false
    encryption = {
      kms_key_arn = "arn:aws:kms:us-east-1:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"
    }
  }

  # O aviso do check "versionamento" é esperado aqui.
  expect_failures = [check.versionamento]

  assert {
    condition     = output.kms_key_arn == "arn:aws:kms:us-east-1:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"
    error_message = "output.kms_key_arn deve ser a chave informada."
  }

  assert {
    condition     = output.versioning_status == "Suspended"
    error_message = "output.versioning_status deve refletir o versionamento suspenso."
  }
}
