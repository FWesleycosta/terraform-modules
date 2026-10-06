# Changelog - aws_s3_bucket

Todas as mudanças relevantes deste módulo são documentadas aqui.

O formato segue o [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e o módulo usa [Versionamento Semântico](https://semver.org/lang/pt-BR/), com tags `aws_s3_bucket/vX.Y.Z`.

## [Não publicado]

## [0.1.0] - 2026-10-06

### Adicionado

- Bucket S3 de uso geral com nome exato (`name`) e validação das regras de nomes da AWS.
- Bloqueio de acesso público total e ACLs desativadas (`BucketOwnerEnforced`).
- Versionamento ligado por padrão (`versioning_enabled`).
- Criptografia SSE-KMS por padrão com S3 Bucket Key, suporte a AES256, `aws:kms:dsse` e chave KMS do cliente (`encryption`); SSE-C sempre bloqueado.
- Policy do bucket que exige TLS 1.2+, com mesclagem de policy adicional (`policy`).
- Regras de lifecycle opcionais (`lifecycle_rules`) com filtros por prefixo, tags e tamanho, transições, expiração e versões não correntes.
- `force_destroy` como opt-in explícito e avisos (`check`) para `force_destroy` ligado e versionamento suspenso.
- Outputs `id`, `arn`, `bucket_regional_domain_name`, `region`, `versioning_status` e `kms_key_arn`.
- Requer Terraform `>= 1.11` e provider AWS `>= 6.40`.
