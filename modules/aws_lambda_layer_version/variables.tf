variable "layer_name" {
  description = "Nome da Lambda layer. De 1 a 140 caracteres: letras, números, hífens e sublinhados. Publicar com um nome existente cria uma nova versão dessa layer."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,140}$", var.layer_name))
    error_message = "layer_name deve ter de 1 a 140 caracteres (letras, números, hífens e sublinhados)."
  }
}

variable "description" {
  description = "Descrição da versão da layer (até 256 caracteres)."
  type        = string
  default     = null

  validation {
    condition     = try(length(var.description), 0) <= 256
    error_message = "description deve ter no máximo 256 caracteres."
  }
}

variable "license_info" {
  description = "Licença do software da layer (até 512 caracteres): identificador SPDX (ex.: MIT), URL da licença ou o texto completo."
  type        = string
  default     = null

  validation {
    condition     = try(length(var.license_info), 0) <= 512
    error_message = "license_info deve ter no máximo 512 caracteres."
  }
}

variable "filename" {
  description = "Caminho local do pacote .zip da layer. Use exatamente uma origem: filename ou s3_object."
  type        = string
  default     = null

  validation {
    condition     = var.filename == null ? true : length(trimspace(var.filename)) > 0
    error_message = "filename não pode ser vazio; use null para não informar."
  }
}

variable "s3_object" {
  description = <<-EOT
    Pacote .zip da layer no S3. Use exatamente uma origem: filename ou s3_object.
    - bucket: nome do bucket (na mesma região da layer).
    - key: chave do objeto.
    - version: versão do objeto (recomendado em bucket versionado: uma nova versão gera nova versão da layer).
  EOT
  type = object({
    bucket  = string
    key     = string
    version = optional(string)
  })
  default = null

  validation {
    condition = var.s3_object == null ? true : alltrue([
      length(trimspace(var.s3_object.bucket)) > 0,
      length(trimspace(var.s3_object.key)) > 0,
      var.s3_object.version == null ? true : length(trimspace(var.s3_object.version)) > 0,
    ])
    error_message = "s3_object.bucket e s3_object.key não podem ser vazios, e s3_object.version, se informado, também não."
  }

  validation {
    condition     = (var.filename == null) != (var.s3_object == null)
    error_message = "Informe exatamente uma origem para o pacote: filename ou s3_object."
  }
}

variable "source_code_hash" {
  description = "Hash SHA256 em base64 do pacote (ex.: filebase64sha256(\"layer.zip\")). Quando muda, uma nova versão da layer é publicada."
  type        = string
  default     = null

  validation {
    condition     = var.source_code_hash == null ? true : length(trimspace(var.source_code_hash)) > 0
    error_message = "source_code_hash não pode ser vazio; use null para não informar."
  }
}

variable "compatible_runtimes" {
  description = "Runtimes compatíveis com a layer (até 15, ex.: python3.12, nodejs22.x). Os valores aceitos são validados pelo provider e dependem da versão dele."
  type        = set(string)
  default     = []
  nullable    = false

  validation {
    condition     = length(var.compatible_runtimes) <= 15
    error_message = "compatible_runtimes aceita no máximo 15 runtimes."
  }
}

variable "compatible_architectures" {
  description = "Arquiteturas compatíveis com a layer: x86_64 e/ou arm64."
  type        = set(string)
  default     = []
  nullable    = false

  validation {
    condition     = alltrue([for a in var.compatible_architectures : contains(["x86_64", "arm64"], a)])
    error_message = "compatible_architectures aceita apenas x86_64 e arm64."
  }
}

variable "skip_destroy" {
  description = "Mantém as versões anteriores da layer na AWS quando uma nova é publicada ou o recurso é destruído. Com false (padrão), a versão anterior é apagada: funções já implantadas continuam funcionando, mas novos deploys não conseguem usar o ARN antigo. Com true, versões ficam órfãs fora do Terraform e geram custo."
  type        = bool
  default     = false
  nullable    = false
}
