# Módulos Terraform

Monorepo de módulos Terraform reutilizáveis. Cada módulo fica em `modules/<nome>/`, tem versionamento próprio e é publicado com tags `<nome>/vX.Y.Z`.

## Módulos

| Módulo | Descrição | Versão atual |
|---|---|---|
| _nenhum módulo publicado ainda_ | | |

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

Módulo novo começa em `0.1.0` e vira `1.0.0` quando a interface estabiliza.

## Como contribuir

- Fluxo trunk-based: branch a partir da `main`, PR de volta para a `main` com squash. Não existe `develop`.
- Commits no padrão Conventional Commits com o nome do módulo como escopo (ex.: `feat(aws_s3_bucket): ...`).
- O `CHANGELOG.md` do módulo é atualizado no mesmo PR da mudança. A tag `<modulo>/vX.Y.Z` é criada na `main` depois do merge.

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

O workflow `.github/workflows/ci.yml` roda em todo PR para a `main`. Ele valida apenas os módulos alterados (ou todos, se mudar a configuração compartilhada da raiz) com Terraform 1.11 (versão mínima suportada) e com a versão mais recente. O check `ci-ok` consolida o resultado e é o que deve ser exigido na proteção da branch.
