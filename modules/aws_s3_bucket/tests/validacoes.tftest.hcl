mock_provider "aws" {}

variables {
  name = "bucket-de-teste"
}

run "nome_com_maiuscula" {
  command = plan
  variables {
    name = "Bucket-De-Teste"
  }
  expect_failures = [var.name]
}

run "nome_com_ponto" {
  command = plan
  variables {
    name = "bucket.de.teste"
  }
  expect_failures = [var.name]
}

run "nome_curto" {
  command = plan
  variables {
    name = "ab"
  }
  expect_failures = [var.name]
}

run "nome_reservado" {
  command = plan
  variables {
    name = "meu-bucket-s3alias"
  }
  expect_failures = [var.name]
}

run "algoritmo_invalido" {
  command = plan
  variables {
    encryption = { sse_algorithm = "SSE-C" }
  }
  expect_failures = [var.encryption]
}

run "kms_com_aes256" {
  command = plan
  variables {
    encryption = {
      sse_algorithm = "AES256"
      kms_key_arn   = "arn:aws:kms:us-east-1:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"
    }
  }
  expect_failures = [var.encryption]
}

run "kms_arn_malformado" {
  command = plan
  variables {
    encryption = { kms_key_arn = "1234abcd-12ab-34cd-56ef-1234567890ab" }
  }
  expect_failures = [var.encryption]
}

run "policy_nao_json" {
  command = plan
  variables {
    policy = "isto nao e json"
  }
  expect_failures = [var.policy]
}

run "ids_duplicados" {
  command = plan
  variables {
    lifecycle_rules = [
      { id = "regra", abort_incomplete_multipart_upload_days = 7 },
      { id = "regra", abort_incomplete_multipart_upload_days = 3 },
    ]
  }
  expect_failures = [var.lifecycle_rules]
}

run "storage_class_invalida" {
  command = plan
  variables {
    lifecycle_rules = [
      { id = "regra", transitions = [{ days = 30, storage_class = "STANDARD" }] },
    ]
  }
  expect_failures = [var.lifecycle_rules]
}

run "dias_zero" {
  command = plan
  variables {
    lifecycle_rules = [
      { id = "regra", expiration = { days = 0 } },
    ]
  }
  expect_failures = [var.lifecycle_rules]
}

run "expiration_ambigua" {
  command = plan
  variables {
    lifecycle_rules = [
      { id = "regra", expiration = { days = 30, expired_object_delete_marker = true } },
    ]
  }
  expect_failures = [var.lifecycle_rules]
}

run "regra_sem_acao" {
  command = plan
  variables {
    lifecycle_rules = [
      { id = "regra", filter = { prefix = "logs/" } },
    ]
  }
  expect_failures = [var.lifecycle_rules]
}
