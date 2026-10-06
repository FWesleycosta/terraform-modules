# Bucket com os defaults seguros do módulo: versionamento, SSE-KMS (chave aws/s3),
# bloqueio de acesso público, ACLs desativadas e TLS 1.2+ obrigatório.

provider "aws" {}

module "aws_s3_bucket" {
  source = "../.."

  name = "exemplo-basico-aws-s3-bucket"

  tags = {
    Environment = "exemplo"
  }
}

output "bucket_arn" {
  description = "ARN do bucket criado."
  value       = module.aws_s3_bucket.arn
}
