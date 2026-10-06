variable "region" {
  description = "Região AWS onde a layer de exemplo é publicada."
  type        = string
  default     = "sa-east-1"
  nullable    = false

  validation {
    condition     = can(regex("^[a-z]{2}(-[a-z]+)+-[0-9]+$", var.region))
    error_message = "region deve ser um código de região AWS válido (ex.: sa-east-1)."
  }
}

variable "layer_name" {
  description = "Nome da layer de exemplo."
  type        = string
  default     = "exemplo-basico"
  nullable    = false

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,140}$", var.layer_name))
    error_message = "layer_name deve ter de 1 a 140 caracteres (letras, números, hífens e sublinhados)."
  }
}
