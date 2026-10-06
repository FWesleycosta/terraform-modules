mock_provider "aws" {}

variables {
  layer_name       = "layer-de-teste"
  filename         = "layer.zip"
  source_code_hash = "aGFzaC1kZS10ZXN0ZQ=="
}

override_resource {
  target = aws_lambda_layer_version.this
  values = {
    arn         = "arn:aws:lambda:us-east-1:111122223333:layer:layer-de-teste:3"
    layer_arn   = "arn:aws:lambda:us-east-1:111122223333:layer:layer-de-teste"
    version     = "3"
    code_sha256 = "aGFzaC1kZS10ZXN0ZQ=="
  }
}

run "outputs" {
  command = apply

  assert {
    condition     = output.arn == "arn:aws:lambda:us-east-1:111122223333:layer:layer-de-teste:3"
    error_message = "output.arn deve ser o ARN com versão."
  }

  assert {
    condition     = output.layer_arn == "arn:aws:lambda:us-east-1:111122223333:layer:layer-de-teste"
    error_message = "output.layer_arn deve ser o ARN sem versão."
  }

  assert {
    condition     = output.arn == "${output.layer_arn}:${output.version}"
    error_message = "output.arn deve ser output.layer_arn seguido da versão."
  }

  assert {
    condition     = output.layer_name == "layer-de-teste"
    error_message = "output.layer_name deve ser o nome da layer."
  }

  assert {
    condition     = output.version == "3"
    error_message = "output.version deve ser a versão publicada."
  }

  assert {
    condition     = output.code_sha256 == "aGFzaC1kZS10ZXN0ZQ=="
    error_message = "output.code_sha256 deve vir do recurso."
  }
}
