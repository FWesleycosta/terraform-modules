output "bucket_id" {
  description = "Nome (id) do bucket criado."
  value       = module.aws_s3_bucket.id
}

output "bucket_arn" {
  description = "ARN do bucket criado."
  value       = module.aws_s3_bucket.arn
}

output "kms_key_arn" {
  description = "ARN da chave KMS usada no bucket."
  value       = module.aws_s3_bucket.kms_key_arn
}
