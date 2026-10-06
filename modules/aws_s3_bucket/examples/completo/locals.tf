locals {
  # Nomes de bucket são globais: conta e região evitam colisão entre quem roda o exemplo.
  bucket_name = "${var.name_prefix}-${data.aws_caller_identity.current.account_id}-${var.region}"

  # ARN montado a partir do nome para a policy adicional, que é avaliada antes de o bucket existir.
  bucket_arn = "arn:${data.aws_partition.current.partition}:s3:::${local.bucket_name}"

  account_root_arn = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
}
