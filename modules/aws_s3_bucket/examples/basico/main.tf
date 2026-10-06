# Bucket com os defaults seguros do módulo: versionamento, SSE-KMS (chave aws/s3),
# bloqueio de acesso público, ACLs desativadas e TLS 1.2+ obrigatório.

module "aws_s3_bucket" {
  source = "../.."

  name = local.bucket_name
  tags = var.tags
}
