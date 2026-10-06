variable "name" {
  description = "Nome exato do bucket S3. De 3 a 63 caracteres: minúsculas, números e hífens, começando e terminando com letra ou número. Pontos não são aceitos porque quebram o TLS em endpoints virtual-hosted."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.name))
    error_message = "name deve ter de 3 a 63 caracteres (minúsculas, números e hífens), começando e terminando com letra ou número."
  }

  validation {
    condition     = !startswith(var.name, "xn--") && !startswith(var.name, "sthree-") && !endswith(var.name, "-s3alias") && !endswith(var.name, "--ol-s3")
    error_message = "name não pode usar prefixos (xn--, sthree-) nem sufixos (-s3alias, --ol-s3) reservados pela AWS."
  }
}

variable "force_destroy" {
  description = "Permite destruir o bucket mesmo com objetos dentro (todos os objetos e versões são apagados). Opt-in explícito: mantenha false em ambientes com dados."
  type        = bool
  default     = false
  nullable    = false
}

variable "versioning_enabled" {
  description = "Liga o versionamento de objetos. Com false o versionamento fica Suspended (a API do S3 não permite voltar para Disabled depois de ligado)."
  type        = bool
  default     = true
  nullable    = false
}

variable "encryption" {
  description = <<-EOT
    Criptografia padrão do bucket (SSE-C é sempre bloqueado).
    - sse_algorithm: AES256, aws:kms ou aws:kms:dsse.
    - kms_key_arn: ARN da chave KMS gerenciada pelo cliente. Com null e algoritmo KMS, usa a chave aws/s3 gerenciada pela AWS. Não pode ser usado com AES256.
    - bucket_key_enabled: liga o S3 Bucket Key para reduzir chamadas ao KMS.
  EOT
  type = object({
    sse_algorithm      = optional(string, "aws:kms")
    kms_key_arn        = optional(string)
    bucket_key_enabled = optional(bool, true)
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["AES256", "aws:kms", "aws:kms:dsse"], var.encryption.sse_algorithm)
    error_message = "encryption.sse_algorithm deve ser AES256, aws:kms ou aws:kms:dsse."
  }

  validation {
    condition     = !(var.encryption.sse_algorithm == "AES256" && var.encryption.kms_key_arn != null)
    error_message = "encryption.kms_key_arn só pode ser usado com sse_algorithm aws:kms ou aws:kms:dsse."
  }

  validation {
    condition     = var.encryption.kms_key_arn == null || can(regex("^arn:aws[a-z-]*:kms:[a-z0-9-]+:[0-9]{12}:(key|alias)/.+$", var.encryption.kms_key_arn))
    error_message = "encryption.kms_key_arn deve ser um ARN de chave ou alias KMS (arn:<partição>:kms:<região>:<conta>:key/<id>)."
  }
}

variable "policy" {
  description = "Policy adicional do bucket, em JSON (ex.: data.aws_iam_policy_document.x.json). É mesclada com os statements do módulo que negam acesso sem TLS 1.2+. Policies públicas são rejeitadas pelo bloqueio de acesso público."
  type        = string
  default     = null

  validation {
    condition     = var.policy == null || can(jsondecode(var.policy))
    error_message = "policy deve ser um documento JSON válido."
  }
}

variable "lifecycle_rules" {
  description = <<-EOT
    Regras de lifecycle (opcional). Lista vazia não cria configuração de lifecycle.
    - id: identificador único da regra (até 255 caracteres).
    - enabled: liga ou desliga a regra.
    - filter: objetos afetados. Sem critérios, a regra vale para o bucket todo; com vários, são combinados com AND.
    - abort_incomplete_multipart_upload_days: dias para abortar uploads multipart incompletos.
    - expiration: days (expira versões correntes) ou expired_object_delete_marker (remove delete markers órfãos), nunca os dois.
    - transitions / noncurrent_version_transitions: mudança de storage class.
    - noncurrent_version_expiration: expiração de versões não correntes.
  EOT
  type = list(object({
    id      = string
    enabled = optional(bool, true)
    filter = optional(object({
      prefix                   = optional(string)
      tags                     = optional(map(string), {})
      object_size_greater_than = optional(number)
      object_size_less_than    = optional(number)
    }), {})
    abort_incomplete_multipart_upload_days = optional(number)
    expiration = optional(object({
      days                         = optional(number)
      expired_object_delete_marker = optional(bool)
    }))
    transitions = optional(list(object({
      days          = number
      storage_class = string
    })), [])
    noncurrent_version_expiration = optional(object({
      noncurrent_days           = number
      newer_noncurrent_versions = optional(number)
    }))
    noncurrent_version_transitions = optional(list(object({
      noncurrent_days           = number
      storage_class             = string
      newer_noncurrent_versions = optional(number)
    })), [])
  }))
  default  = []
  nullable = false

  validation {
    condition     = alltrue([for r in var.lifecycle_rules : length(trimspace(r.id)) > 0 && length(r.id) <= 255])
    error_message = "lifecycle_rules[*].id deve ter de 1 a 255 caracteres."
  }

  validation {
    condition     = length(distinct([for r in var.lifecycle_rules : r.id])) == length(var.lifecycle_rules)
    error_message = "lifecycle_rules[*].id deve ser único."
  }

  validation {
    condition = alltrue(flatten([
      for r in var.lifecycle_rules : [
        for s in concat([for t in r.transitions : t.storage_class], [for t in r.noncurrent_version_transitions : t.storage_class]) :
        contains(["GLACIER", "STANDARD_IA", "ONEZONE_IA", "INTELLIGENT_TIERING", "DEEP_ARCHIVE", "GLACIER_IR"], s)
      ]
    ]))
    error_message = "storage_class deve ser GLACIER, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, DEEP_ARCHIVE ou GLACIER_IR."
  }

  validation {
    condition = alltrue(flatten([
      for r in var.lifecycle_rules : concat(
        [for t in r.transitions : t.days >= 0],
        [for t in r.noncurrent_version_transitions : t.noncurrent_days > 0],
        [r.abort_incomplete_multipart_upload_days == null ? true : r.abort_incomplete_multipart_upload_days > 0],
        [try(r.expiration.days, null) == null ? true : r.expiration.days > 0],
        [r.noncurrent_version_expiration == null ? true : r.noncurrent_version_expiration.noncurrent_days > 0],
      )
    ]))
    error_message = "Os dias das regras de lifecycle devem ser maiores que 0 (transitions[*].days aceita 0)."
  }

  validation {
    condition = alltrue([
      for r in var.lifecycle_rules :
      r.expiration == null ? true : (
        (try(r.expiration.days, null) != null) != (try(r.expiration.expired_object_delete_marker, null) != null)
      )
    ])
    error_message = "lifecycle_rules[*].expiration deve ter exatamente um entre days e expired_object_delete_marker."
  }

  validation {
    condition = alltrue([
      for r in var.lifecycle_rules :
      r.abort_incomplete_multipart_upload_days != null || r.expiration != null || length(r.transitions) > 0 ||
      r.noncurrent_version_expiration != null || length(r.noncurrent_version_transitions) > 0
    ])
    error_message = "Cada regra de lifecycle precisa de pelo menos uma ação (expiration, transitions, noncurrent_*, abort_incomplete_multipart_upload_days)."
  }
}

variable "tags" {
  description = "Tags adicionais aplicadas a todos os recursos que aceitam tags."
  type        = map(string)
  default     = {}
  nullable    = false
}
