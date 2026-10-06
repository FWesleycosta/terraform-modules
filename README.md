# Módulos Terraform

Monorepo de módulos Terraform reutilizáveis. Cada módulo fica em `modules/<nome>/`, tem versionamento próprio e é publicado com tags `<nome>/vX.Y.Z`.

## Módulos

| Módulo | Descrição | Versão atual |
|---|---|---|
| [aws_lambda_layer_version](modules/aws_lambda_layer_version) | Versão de Lambda layer a partir de pacote local ou no S3, com validação das regras da API | [0.1.0](modules/aws_lambda_layer_version/CHANGELOG.md) |
| [aws_s3_bucket](modules/aws_s3_bucket) | Bucket S3 seguro: versionamento, criptografia SSE-KMS, bloqueio de acesso público, TLS obrigatório e lifecycle opcional | [0.1.0](modules/aws_s3_bucket/CHANGELOG.md) |

## Como consumir

Referencie o módulo pelo caminho dentro do monorepo e fixe a versão pela tag do módulo:

```hcl
module "exemplo" {
  source = "git::ssh://git@github.com/FWesleycosta/terraform-modules.git//modules/<modulo>?ref=<modulo>/vX.Y.Z"

  # variáveis do módulo
}
```

Via HTTPS:

```hcl
source = "git::https://github.com/FWesleycosta/terraform-modules.git//modules/<modulo>?ref=<modulo>/vX.Y.Z"
```

Requisitos para quem consome:

- Terraform `>= 1.11`.
- Os módulos declaram providers só com limite inferior (ex.: `>= 6.0`). Quem fixa a versão exata dos providers, e versiona o `.terraform.lock.hcl`, é o módulo raiz que consome.
- Os módulos não declaram blocos `provider`: a configuração do provider (região, credenciais, aliases) é do consumidor.

## Versionamento

Cada módulo segue [SemVer](https://semver.org/lang/pt-BR/) de forma independente, com histórico no próprio `CHANGELOG.md`:

- **MAJOR**: remove ou renomeia variável ou output, muda tipo, muda default que altera recursos existentes, exige Terraform ou provider mais novo.
- **MINOR**: nova variável opcional, novo output, nova funcionalidade.
- **PATCH**: correção sem mudança de interface.

Módulo novo começa em `0.1.0`. Na série `0.x`, quebra de interface sobe o MINOR. A passagem para `1.0.0` é decisão do responsável pelo repositório.

## Como contribuir

- Fluxo trunk-based: branch a partir da `main`, PR de volta para a `main` com squash. Não existe `develop`.
- Commits no padrão Conventional Commits com o nome do módulo como escopo (ex.: `feat(aws_s3_bucket): ...`).
- O `CHANGELOG.md` do módulo, com a data do merge na seção da versão, e a linha dele no índice "Módulos" deste README, com a versão apontando para esse CHANGELOG, são atualizados no mesmo PR da mudança. A tag `<modulo>/vX.Y.Z` é criada na `main` no mesmo dia do merge, seguindo o runbook [Publicar uma versão de módulo](docs/runbooks/publicar-versao-de-modulo.md). Tag publicada nunca é apagada nem movida.

Estrutura esperada de um módulo:

```
modules/<nome>/
  main.tf  variables.tf  outputs.tf  versions.tf
  README.md  CHANGELOG.md
  examples/basico/
  tests/*.tftest.hcl
```

### Validação local

As mesmas verificações do CI, a partir da raiz do repositório:

```sh
m=modules/<nome>

terraform -chdir=$m fmt -check -recursive
terraform -chdir=$m init -backend=false
terraform -chdir=$m validate
for ex in $m/examples/*/; do
  terraform -chdir=$ex init -backend=false && terraform -chdir=$ex validate
done
terraform -chdir=$m test

tflint --init --config "$PWD/.tflint.hcl"
tflint --chdir $m --config "$PWD/.tflint.hcl"

trivy config --exit-code 1 --severity HIGH,CRITICAL $m

terraform-docs -c .terraform-docs.yml $m                  # atualiza o README do módulo
terraform-docs -c .terraform-docs.yml --output-check $m   # só confere
```

### CI

O workflow `.github/workflows/ci.yml` roda em todo PR para a `main` e também pode ser disparado à mão (`workflow_dispatch`). Ele valida apenas os módulos alterados (ou todos, se mudar a configuração compartilhada da raiz) com Terraform 1.11 (versão mínima suportada) e com a versão mais recente. O check `ci-ok` consolida o resultado. O merge com o `ci-ok` vermelho é proibido por convenção. Como a `main` não tem proteção de branch, o GitHub não bloqueia esse merge: confira o `ci-ok` antes de fazer o merge. Os detalhes estão em [CI e release dos módulos](docs/pipelines/ci-e-release-de-modulos.md).
