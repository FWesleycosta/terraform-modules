mock_provider "aws" {}

variables {
  layer_name = "layer-de-teste"
}

run "origem_s3_completa" {
  command = plan

  variables {
    s3_object = {
      bucket  = "bucket-de-pacotes"
      key     = "layers/layer-de-teste.zip"
      version = "3HL4kqtJlcpXroDTDmJ.rmSpXd3dIbrHY"
    }
    description              = "Utilitários compartilhados"
    license_info             = "MIT"
    compatible_runtimes      = ["python3.12", "python3.13"]
    compatible_architectures = ["x86_64", "arm64"]
  }

  assert {
    condition = alltrue([
      aws_lambda_layer_version.this.s3_bucket == "bucket-de-pacotes",
      aws_lambda_layer_version.this.s3_key == "layers/layer-de-teste.zip",
      aws_lambda_layer_version.this.s3_object_version == "3HL4kqtJlcpXroDTDmJ.rmSpXd3dIbrHY",
    ])
    error_message = "A origem S3 deve preencher s3_bucket, s3_key e s3_object_version."
  }

  assert {
    condition     = aws_lambda_layer_version.this.filename == null
    error_message = "Com s3_object, filename deve ficar nulo."
  }

  assert {
    condition     = aws_lambda_layer_version.this.license_info == "MIT" && aws_lambda_layer_version.this.description == "Utilitários compartilhados"
    error_message = "license_info e description devem ser repassados ao recurso."
  }

  assert {
    condition     = aws_lambda_layer_version.this.compatible_runtimes == toset(["python3.12", "python3.13"])
    error_message = "compatible_runtimes deve ser repassado ao recurso."
  }

  assert {
    condition     = aws_lambda_layer_version.this.compatible_architectures == toset(["x86_64", "arm64"])
    error_message = "compatible_architectures deve ser repassado ao recurso."
  }
}

run "skip_destroy" {
  command = plan

  variables {
    filename         = "layer.zip"
    source_code_hash = "aGFzaC1kZS10ZXN0ZQ=="
    skip_destroy     = true
  }

  assert {
    condition     = aws_lambda_layer_version.this.skip_destroy == true
    error_message = "skip_destroy deve respeitar o opt-in."
  }
}

run "s3_sem_versao_com_hash" {
  command = plan

  variables {
    s3_object = {
      bucket = "bucket-de-pacotes"
      key    = "layers/layer-de-teste.zip"
    }
    source_code_hash = "aGFzaC1kZS10ZXN0ZQ=="
  }

  assert {
    condition     = aws_lambda_layer_version.this.s3_object_version == null
    error_message = "Sem s3_object.version, s3_object_version deve ficar nulo."
  }
}

run "sem_deteccao_de_mudancas" {
  command = plan

  variables {
    filename = "layer.zip"
  }

  # O aviso do check "deteccao_de_mudancas" é esperado aqui.
  expect_failures = [check.deteccao_de_mudancas]

  # source_code_hash é Computed no provider e fica desconhecido no plan quando não informado.
  assert {
    condition     = aws_lambda_layer_version.this.filename == "layer.zip"
    error_message = "A layer deve continuar sendo planejada; o check só emite um aviso."
  }
}
