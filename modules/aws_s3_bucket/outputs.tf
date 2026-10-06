output "id" {
  description = "Nome do bucket."
  value       = aws_s3_bucket.this.id
}

output "arn" {
  description = "ARN do bucket."
  value       = aws_s3_bucket.this.arn
}

output "bucket_regional_domain_name" {
  description = "Nome de domínio regional do bucket (ex.: para origens do CloudFront)."
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "region" {
  description = "Região AWS onde o bucket foi criado."
  value       = aws_s3_bucket.this.bucket_region
}

output "versioning_status" {
  description = "Status do versionamento: Enabled ou Suspended."
  value       = aws_s3_bucket_versioning.this.versioning_configuration[0].status
}

output "kms_key_arn" {
  description = "ARN da chave KMS gerenciada pelo cliente usada na criptografia, ou null quando o bucket usa AES256 ou a chave aws/s3 gerenciada pela AWS."
  value       = var.encryption.kms_key_arn
}
