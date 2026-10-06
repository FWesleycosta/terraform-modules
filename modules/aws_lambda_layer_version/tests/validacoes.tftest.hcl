mock_provider "aws" {}

variables {
  layer_name       = "layer-de-teste"
  filename         = "layer.zip"
  source_code_hash = "aGFzaC1kZS10ZXN0ZQ=="
}

run "duas_origens" {
  command = plan
  variables {
    s3_object = {
      bucket = "bucket-de-pacotes"
      key    = "layers/layer.zip"
    }
  }
  expect_failures = [var.s3_object]
}

run "nenhuma_origem" {
  command = plan
  variables {
    filename = null
  }
  expect_failures = [var.s3_object]
}

run "s3_key_vazia" {
  command = plan
  variables {
    filename = null
    s3_object = {
      bucket = "bucket-de-pacotes"
      key    = " "
    }
  }
  expect_failures = [var.s3_object]
}

run "s3_version_vazia" {
  command = plan
  variables {
    filename = null
    s3_object = {
      bucket  = "bucket-de-pacotes"
      key     = "layers/layer.zip"
      version = ""
    }
  }
  expect_failures = [var.s3_object]
}

run "filename_vazio" {
  command = plan
  variables {
    filename = ""
  }
  expect_failures = [var.filename]
}

run "nome_com_ponto" {
  command = plan
  variables {
    layer_name = "layer.de.teste"
  }
  expect_failures = [var.layer_name]
}

run "nome_com_espaco" {
  command = plan
  variables {
    layer_name = "layer de teste"
  }
  expect_failures = [var.layer_name]
}

run "nome_longo" {
  command = plan
  variables {
    layer_name = join("", [for i in range(141) : "a"])
  }
  expect_failures = [var.layer_name]
}

run "arquitetura_invalida" {
  command = plan
  variables {
    compatible_architectures = ["x86_64", "aarch64"]
  }
  expect_failures = [var.compatible_architectures]
}

run "runtimes_demais" {
  command = plan
  variables {
    compatible_runtimes = [
      "nodejs18.x", "nodejs20.x", "nodejs22.x", "nodejs24.x",
      "python3.9", "python3.10", "python3.11", "python3.12", "python3.13", "python3.14",
      "java11", "java17", "java21", "ruby3.3", "ruby3.4", "provided.al2023",
    ]
  }
  expect_failures = [var.compatible_runtimes]
}

run "hash_vazio" {
  command = plan
  variables {
    source_code_hash = "  "
  }
  expect_failures = [var.source_code_hash]
}

run "description_longa" {
  command = plan
  variables {
    description = join("", [for i in range(257) : "d"])
  }
  expect_failures = [var.description]
}

run "license_info_longa" {
  command = plan
  variables {
    license_info = join("", [for i in range(513) : "l"])
  }
  expect_failures = [var.license_info]
}
