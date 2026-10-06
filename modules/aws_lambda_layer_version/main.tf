resource "aws_lambda_layer_version" "this" {
  layer_name   = var.layer_name
  description  = var.description
  license_info = var.license_info

  filename          = var.filename
  s3_bucket         = try(var.s3_object.bucket, null)
  s3_key            = try(var.s3_object.key, null)
  s3_object_version = try(var.s3_object.version, null)
  source_code_hash  = var.source_code_hash

  compatible_runtimes      = var.compatible_runtimes
  compatible_architectures = var.compatible_architectures

  skip_destroy = var.skip_destroy
}

check "deteccao_de_mudancas" {
  assert {
    condition     = var.source_code_hash != null || try(var.s3_object.version, null) != null
    error_message = "Sem source_code_hash nem s3_object.version, mudanças no conteúdo do pacote não geram nova versão da layer. Informe source_code_hash (ex.: filebase64sha256(\"layer.zip\")) ou a versão do objeto no S3."
  }
}
