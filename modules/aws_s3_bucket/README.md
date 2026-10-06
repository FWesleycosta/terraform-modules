# Módulo aws_s3_bucket

Cria um bucket S3 de uso geral, seguro por padrão:

- **Bloqueio de acesso público** total (os quatro controles ligados, sem opt-out).
- **ACLs desativadas** (`BucketOwnerEnforced`): o dono do bucket é dono de todos os objetos.
- **Versionamento** ligado (pode ser suspenso com `versioning_enabled = false`).
- **Criptografia** SSE-KMS com S3 Bucket Key; usa a chave `aws/s3` gerenciada pela AWS ou uma chave do cliente (`encryption.kms_key_arn`). SSE-C é sempre bloqueado.
- **TLS obrigatório**: a policy do bucket nega qualquer acesso sem HTTPS ou com TLS anterior a 1.2. Uma policy adicional pode ser mesclada com `policy`.
- **Regras de lifecycle opcionais** (`lifecycle_rules`), com filtros por prefixo, tags e tamanho.
- `force_destroy` desligado por padrão.

Fora do escopo (use outros recursos ou módulos em composição): logging de acesso, replicação, object lock, website, notificações e buckets de diretório.

## Uso

```hcl
module "aws_s3_bucket" {
  source = "git::ssh://git@github.com/FWesleycosta/terraform-modules.git//modules/aws_s3_bucket?ref=aws_s3_bucket/v0.1.0"

  name = "minha-empresa-dados-prod"

  tags = {
    Environment = "prod"
  }
}
```

Com chave KMS do cliente e lifecycle:

```hcl
module "aws_s3_bucket" {
  source = "git::ssh://git@github.com/FWesleycosta/terraform-modules.git//modules/aws_s3_bucket?ref=aws_s3_bucket/v0.1.0"

  name = "minha-empresa-logs-prod"

  encryption = {
    kms_key_arn = aws_kms_key.logs.arn
  }

  lifecycle_rules = [
    {
      id                                     = "logs"
      filter                                 = { prefix = "logs/" }
      abort_incomplete_multipart_upload_days = 7
      transitions                            = [{ days = 30, storage_class = "STANDARD_IA" }]
      expiration                             = { days = 365 }
      noncurrent_version_expiration          = { noncurrent_days = 30 }
    },
  ]
}
```

Veja também [`examples/basico`](examples/basico) e [`examples/completo`](examples/completo).

## Observações

- O nome do bucket é exato e global. Pontos não são aceitos, para não quebrar o TLS em endpoints virtual-hosted.
- No filtro do lifecycle, sem critérios a regra vale para o bucket todo; com um critério ele vai direto no `filter`; com vários, eles são combinados com AND.
- A AWS recomenda esperar cerca de 15 minutos depois de ligar o versionamento antes de gravar objetos no bucket.
- A região do bucket é a do provider `aws` passado ao módulo.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.40 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.40 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_name"></a> [name](#input\_name) | Nome exato do bucket S3. De 3 a 63 caracteres: minúsculas, números e hífens, começando e terminando com letra ou número. Pontos não são aceitos porque quebram o TLS em endpoints virtual-hosted. | `string` | n/a | yes |
| <a name="input_encryption"></a> [encryption](#input\_encryption) | Criptografia padrão do bucket (SSE-C é sempre bloqueado).<br/>- sse\_algorithm: AES256, aws:kms ou aws:kms:dsse.<br/>- kms\_key\_arn: ARN da chave KMS gerenciada pelo cliente. Com null e algoritmo KMS, usa a chave aws/s3 gerenciada pela AWS. Não pode ser usado com AES256.<br/>- bucket\_key\_enabled: liga o S3 Bucket Key para reduzir chamadas ao KMS. | <pre>object({<br/>    sse_algorithm      = optional(string, "aws:kms")<br/>    kms_key_arn        = optional(string)<br/>    bucket_key_enabled = optional(bool, true)<br/>  })</pre> | `{}` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Permite destruir o bucket mesmo com objetos dentro (todos os objetos e versões são apagados). Opt-in explícito: mantenha false em ambientes com dados. | `bool` | `false` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | Regras de lifecycle (opcional). Lista vazia não cria configuração de lifecycle.<br/>- id: identificador único da regra (até 255 caracteres).<br/>- enabled: liga ou desliga a regra.<br/>- filter: objetos afetados. Sem critérios, a regra vale para o bucket todo; com vários, são combinados com AND.<br/>- abort\_incomplete\_multipart\_upload\_days: dias para abortar uploads multipart incompletos.<br/>- expiration: days (expira versões correntes) ou expired\_object\_delete\_marker (remove delete markers órfãos), nunca os dois.<br/>- transitions / noncurrent\_version\_transitions: mudança de storage class.<br/>- noncurrent\_version\_expiration: expiração de versões não correntes. | <pre>list(object({<br/>    id      = string<br/>    enabled = optional(bool, true)<br/>    filter = optional(object({<br/>      prefix                   = optional(string)<br/>      tags                     = optional(map(string), {})<br/>      object_size_greater_than = optional(number)<br/>      object_size_less_than    = optional(number)<br/>    }), {})<br/>    abort_incomplete_multipart_upload_days = optional(number)<br/>    expiration = optional(object({<br/>      days                         = optional(number)<br/>      expired_object_delete_marker = optional(bool)<br/>    }))<br/>    transitions = optional(list(object({<br/>      days          = number<br/>      storage_class = string<br/>    })), [])<br/>    noncurrent_version_expiration = optional(object({<br/>      noncurrent_days           = number<br/>      newer_noncurrent_versions = optional(number)<br/>    }))<br/>    noncurrent_version_transitions = optional(list(object({<br/>      noncurrent_days           = number<br/>      storage_class             = string<br/>      newer_noncurrent_versions = optional(number)<br/>    })), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | Policy adicional do bucket, em JSON (ex.: data.aws\_iam\_policy\_document.x.json). É mesclada com os statements do módulo que negam acesso sem TLS 1.2+. Policies públicas são rejeitadas pelo bloqueio de acesso público. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags adicionais aplicadas a todos os recursos que aceitam tags. | `map(string)` | `{}` | no |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled) | Liga o versionamento de objetos. Com false o versionamento fica Suspended (a API do S3 não permite voltar para Disabled depois de ligado). | `bool` | `true` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | ARN do bucket. |
| <a name="output_bucket_regional_domain_name"></a> [bucket\_regional\_domain\_name](#output\_bucket\_regional\_domain\_name) | Nome de domínio regional do bucket (ex.: para origens do CloudFront). |
| <a name="output_id"></a> [id](#output\_id) | Nome do bucket. |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | ARN da chave KMS gerenciada pelo cliente usada na criptografia, ou null quando o bucket usa AES256 ou a chave aws/s3 gerenciada pela AWS. |
| <a name="output_region"></a> [region](#output\_region) | Região AWS onde o bucket foi criado. |
| <a name="output_versioning_status"></a> [versioning\_status](#output\_versioning\_status) | Status do versionamento: Enabled ou Suspended. |
<!-- END_TF_DOCS -->
