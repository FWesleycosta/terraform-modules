output "bucket_id" {
  description = "Nome (id) do bucket criado."
  value       = module.aws_s3_bucket.id
}

output "bucket_arn" {
  description = "ARN do bucket criado."
  value       = module.aws_s3_bucket.arn
}
