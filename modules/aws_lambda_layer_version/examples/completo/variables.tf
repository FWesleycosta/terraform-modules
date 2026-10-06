variable "region" {
  description = "Região AWS onde o bucket de pacotes e a layer de exemplo são criados (precisam estar na mesma região)."
  type        = string
  default     = "sa-east-1"
  nullable    = false

  validation {
    condition     = can(regex("^[a-z]{2}(-[a-z]+)+-[0-9]+$", var.region))
    error_message = "region deve ser um código de região AWS válido (ex.: sa-east-1)."
  }
}

variable "name_prefix" {
  description = "Prefixo dos nomes. O bucket se chama <name_prefix>-<id da conta>-<região>, para ser globalmente único, e a layer <name_prefix>."
  type        = string
  default     = "exemplo-completo"
  nullable    = false

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{0,28}[a-z0-9]$", var.name_prefix))
    error_message = "name_prefix deve ter de 2 a 30 caracteres (minúsculas, números e hífens), começando e terminando com letra ou número."
  }
}

variable "tags" {
  description = "Tags aplicadas aos recursos do exemplo que aceitam tags (a layer não aceita)."
  type        = map(string)
  default = {
    Environment = "exemplo"
  }
  nullable = false
}
