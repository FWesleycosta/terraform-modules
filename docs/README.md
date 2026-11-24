# Documentação

| Documento | Tipo | Do que trata |
|---|---|---|
| [Arquitetura do monorepo de módulos](arquitetura/monorepo-de-modulos.md) | Arquitetura | O que o repositório entrega, os três módulos (AWS e Proxmox VE), com quem se relaciona, o que executa e o que publica (diagramas C4 de contexto e de contêineres), o consumo de uma versão, a segurança e a proteção da `main` |
| [CI, release dos módulos e portal](pipelines/ci-e-release-de-modulos.md) | Pipeline | Como o CI valida os módulos em cada PR, como uma versão chega a ser publicada e como o portal de documentação é publicado no GitHub Pages |
| [Publicar uma versão de módulo](runbooks/publicar-versao-de-modulo.md) | Runbook | Passo a passo para criar a tag e a release de um módulo depois do merge, inclusive a primeira versão de um módulo novo |
| [Modelo dos diagramas C4](diagramas/modelo.yaml) | Referência | Fonte dos diagramas `.drawio.svg` desta pasta; o cabeçalho diz como gerar de novo |

O portal publicado, com esta pasta, o README da raiz e os READMEs dos módulos numa página só, fica em https://fwesleycosta.github.io/terraform-modules/.
