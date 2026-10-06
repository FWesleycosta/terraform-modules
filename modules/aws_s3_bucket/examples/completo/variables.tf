variable "region" {
  description = "Região AWS onde o bucket e a chave KMS de exemplo são criados."
  type        = string
  default     = "sa-east-1"
  nullable    = false

  validation {
    condition     = can(regex("^[a-z]{2}(-[a-z]+)+-[0-9]+$", var.region))
    error_message = "region deve ser um código de região AWS válido (ex.: sa-east-1)."
  }
}

variable "name_prefix" {
  description = "Prefixo do nome do bucket. O nome final é <name_prefix>-<id da conta>-<região>, para ser globalmente único."
  type        = string
  default     = "exemplo-completo"
  nullable    = false

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{0,28}[a-z0-9]$", var.name_prefix))
    error_message = "name_prefix deve ter de 2 a 30 caracteres (minúsculas, números e hífens), começando e terminando com letra ou número."
  }
}

variable "tags" {
  description = "Tags aplicadas a todos os recursos do exemplo."
  type        = map(string)
  default = {
    Environment = "exemplo"
  }
  nullable = false
}
