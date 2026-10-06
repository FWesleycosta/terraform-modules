# Changelog - aws_lambda_layer_version

Todas as mudanças relevantes deste módulo são documentadas aqui.

O formato segue o [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e o módulo usa [Versionamento Semântico](https://semver.org/lang/pt-BR/), com tags `aws_lambda_layer_version/vX.Y.Z`.

## [Não publicado]

## [0.1.0] - 2026-10-06

### Adicionado

- Versão de Lambda layer (`aws_lambda_layer_version`) com nome validado pelas regras da API (`layer_name`).
- Origem do pacote local (`filename`) ou no S3 (`s3_object`, com bucket, key e versão opcional do objeto), com validação de que exatamente uma origem é usada.
- `source_code_hash` para publicar nova versão quando o pacote muda, e aviso (`check`) quando não há hash nem versão do objeto.
- `description`, `license_info`, `compatible_runtimes` e `compatible_architectures` opcionais, com validação dos limites da API.
- `skip_destroy` desligado por padrão.
- Outputs `arn` (com versão), `layer_arn` (sem versão), `layer_name`, `version` e `code_sha256`.
- Requer Terraform `>= 1.11` e provider AWS `>= 6.0`.
