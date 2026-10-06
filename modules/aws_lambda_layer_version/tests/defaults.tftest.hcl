mock_provider "aws" {}

variables {
  layer_name       = "layer-de-teste"
  filename         = "layer.zip"
  source_code_hash = "aGFzaC1kZS10ZXN0ZQ=="
}

run "defaults" {
  command = plan

  assert {
    condition     = aws_lambda_layer_version.this.layer_name == "layer-de-teste"
    error_message = "A layer deve usar o layer_name informado."
  }

  assert {
    condition     = aws_lambda_layer_version.this.filename == "layer.zip"
    error_message = "A origem deve ser o filename informado."
  }

  assert {
    condition     = aws_lambda_layer_version.this.source_code_hash == "aGFzaC1kZS10ZXN0ZQ=="
    error_message = "source_code_hash deve ser repassado ao recurso."
  }

  assert {
    condition = alltrue([
      aws_lambda_layer_version.this.s3_bucket == null,
      aws_lambda_layer_version.this.s3_key == null,
      aws_lambda_layer_version.this.s3_object_version == null,
    ])
    error_message = "Com filename, os argumentos s3_* devem ficar nulos."
  }

  assert {
    condition     = aws_lambda_layer_version.this.skip_destroy == false
    error_message = "skip_destroy deve ser false por padrão."
  }

  assert {
    condition     = aws_lambda_layer_version.this.description == null && aws_lambda_layer_version.this.license_info == null
    error_message = "description e license_info devem ser nulos por padrão."
  }

  assert {
    condition     = length(aws_lambda_layer_version.this.compatible_runtimes) == 0 && length(aws_lambda_layer_version.this.compatible_architectures) == 0
    error_message = "compatible_runtimes e compatible_architectures devem ser vazios por padrão."
  }
}
