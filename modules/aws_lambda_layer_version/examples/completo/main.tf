# Layer publicada a partir de um pacote no S3: o pacote é enviado para um bucket
# versionado e a layer referencia a versão exata do objeto, de modo que cada novo
# upload gera uma nova versão da layer.

module "aws_s3_bucket" {
  source = "../../../aws_s3_bucket"

  name = local.bucket_name
  tags = var.tags
}

resource "aws_s3_object" "layer" {
  bucket      = module.aws_s3_bucket.id
  key         = local.layer_key
  source      = data.archive_file.layer.output_path
  source_hash = data.archive_file.layer.output_base64sha256
  tags        = var.tags
}

module "aws_lambda_layer_version" {
  source = "../.."

  layer_name   = var.name_prefix
  description  = "Layer de exemplo publicada a partir do S3"
  license_info = "MIT"

  s3_object = {
    bucket  = aws_s3_object.layer.bucket
    key     = aws_s3_object.layer.key
    version = aws_s3_object.layer.version_id
  }
  source_code_hash = data.archive_file.layer.output_base64sha256

  compatible_runtimes      = ["python3.12", "python3.13"]
  compatible_architectures = ["x86_64", "arm64"]
}
