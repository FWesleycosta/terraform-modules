# Layer publicada a partir de um pacote local, com source_code_hash para que
# mudanças no conteúdo gerem uma nova versão.

module "aws_lambda_layer_version" {
  source = "../.."

  layer_name       = var.layer_name
  description      = "Layer de exemplo do módulo aws_lambda_layer_version"
  filename         = data.archive_file.layer.output_path
  source_code_hash = data.archive_file.layer.output_base64sha256

  compatible_runtimes = ["python3.12"]
}
