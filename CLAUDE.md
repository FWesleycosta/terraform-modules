# Monorepo de módulos Terraform

## Git
- Trunk-based: branches saem da main e voltam para a main via PR com squash. Não existe develop.
- Releases são por módulo: tags `<modulo>/vX.Y.Z` criadas na main depois do merge. Siga o runbook docs/runbooks/publicar-versao-de-modulo.md, e não o fluxo de release do padrao-git.
- O escopo dos commits é o nome do módulo (ex.: `feat(aws_s3_bucket): ...`).
