locals {
  # Nomes de bucket são globais: conta e região evitam colisão entre quem roda o exemplo.
  bucket_name = "${var.name_prefix}-${data.aws_caller_identity.current.account_id}-${var.region}"
}
