output "layer_version_arn" {
  description = "ARN da versão da layer (use em layers de aws_lambda_function)."
  value       = module.aws_lambda_layer_version.arn
}

output "layer_arn" {
  description = "ARN da layer sem a versão."
  value       = module.aws_lambda_layer_version.layer_arn
}

output "layer_version" {
  description = "Número da versão publicada."
  value       = module.aws_lambda_layer_version.version
}

output "bucket_id" {
  description = "Bucket onde o pacote da layer foi armazenado."
  value       = module.aws_s3_bucket.id
}
