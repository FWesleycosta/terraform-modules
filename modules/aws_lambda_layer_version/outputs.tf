output "arn" {
  description = "ARN da versão da layer (com o número da versão). É o valor usado em layers de aws_lambda_function."
  value       = aws_lambda_layer_version.this.arn
}

output "layer_arn" {
  description = "ARN da layer sem a versão."
  value       = aws_lambda_layer_version.this.layer_arn
}

output "layer_name" {
  description = "Nome da layer."
  value       = aws_lambda_layer_version.this.layer_name
}

output "version" {
  description = "Número da versão publicada da layer."
  value       = aws_lambda_layer_version.this.version
}

output "code_sha256" {
  description = "SHA256 em base64 do pacote publicado, calculado pela AWS."
  value       = aws_lambda_layer_version.this.code_sha256
}
