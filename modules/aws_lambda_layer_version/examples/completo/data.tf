data "aws_caller_identity" "current" {}

# Empacota o conteúdo de layer/ no formato esperado pelo runtime Python (python/<módulo>.py).
data "archive_file" "layer" {
  type        = "zip"
  source_dir  = "${path.module}/layer"
  output_path = "${path.module}/build/layer.zip"
}
