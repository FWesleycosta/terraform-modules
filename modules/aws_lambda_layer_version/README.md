# Módulo aws_lambda_layer_version

Publica uma versão de Lambda layer a partir de um pacote `.zip`:

- **Origem local ou no S3**: exatamente uma entre `filename` e `s3_object` (bucket, key e, de preferência, a versão do objeto).
- **Detecção de mudanças**: `source_code_hash` (ou `s3_object.version`) faz cada mudança no pacote publicar uma nova versão. Sem nenhum dos dois, o módulo emite um aviso (`check`).
- **Metadados**: `description`, `license_info` (SPDX, URL ou texto), `compatible_runtimes` e `compatible_architectures`, todos validados pelos limites da API.
- **Retenção de versões** (`skip_destroy`) desligada por padrão, como no provider.

Fora do escopo (use outros recursos ou módulos em composição): permissões de uso da layer por outras contas ou organizações (`aws_lambda_layer_version_permission`), upload do pacote para o S3 e a própria função Lambda.

## Uso

Com pacote local:

```hcl
module "aws_lambda_layer_version" {
  source = "git::ssh://git@github.com/FWesleycosta/terraform-modules.git//modules/aws_lambda_layer_version?ref=aws_lambda_layer_version/v0.1.0"

  layer_name       = "utilitarios-python"
  filename         = "build/layer.zip"
  source_code_hash = filebase64sha256("build/layer.zip")

  compatible_runtimes      = ["python3.12"]
  compatible_architectures = ["arm64"]
}
```

Com pacote no S3 (bucket versionado, na mesma região da layer):

```hcl
module "aws_lambda_layer_version" {
  source = "git::ssh://git@github.com/FWesleycosta/terraform-modules.git//modules/aws_lambda_layer_version?ref=aws_lambda_layer_version/v0.1.0"

  layer_name   = "utilitarios-python"
  license_info = "MIT"

  s3_object = {
    bucket  = aws_s3_object.layer.bucket
    key     = aws_s3_object.layer.key
    version = aws_s3_object.layer.version_id
  }

  compatible_runtimes = ["python3.12", "python3.13"]
}

resource "aws_lambda_function" "exemplo" {
  # ...
  layers = [module.aws_lambda_layer_version.arn]
}
```

Veja também [`examples/basico`](examples/basico) e [`examples/completo`](examples/completo).

## Observações

- `arn` é o ARN **com** a versão (o que vai em `layers` da função); `layer_arn` é o ARN **sem** a versão.
- Qualquer mudança de argumento publica uma nova versão. Com `skip_destroy = false` (padrão), a versão anterior é apagada: funções já implantadas continuam funcionando, mas novos deploys não conseguem usar o ARN antigo. Com `skip_destroy = true`, as versões antigas ficam na AWS fora do Terraform (e geram custo de armazenamento).
- Os valores de `compatible_runtimes` são validados pelo provider e dependem da versão dele: `nodejs24.x`, `python3.14` e `java25` exigem o provider AWS `>= 6.21`; `ruby4.0` exige `>= 6.45`.
- O recurso `aws_lambda_layer_version` não aceita tags, por isso o módulo não tem a variável `tags`.
- A região da layer é a do provider `aws` passado ao módulo; o bucket de `s3_object` precisa estar na mesma região.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_lambda_layer_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_layer_version) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_layer_name"></a> [layer\_name](#input\_layer\_name) | Nome da Lambda layer. De 1 a 140 caracteres: letras, números, hífens e sublinhados. Publicar com um nome existente cria uma nova versão dessa layer. | `string` | n/a | yes |
| <a name="input_compatible_architectures"></a> [compatible\_architectures](#input\_compatible\_architectures) | Arquiteturas compatíveis com a layer: x86\_64 e/ou arm64. | `set(string)` | `[]` | no |
| <a name="input_compatible_runtimes"></a> [compatible\_runtimes](#input\_compatible\_runtimes) | Runtimes compatíveis com a layer (até 15, ex.: python3.12, nodejs22.x). Os valores aceitos são validados pelo provider e dependem da versão dele. | `set(string)` | `[]` | no |
| <a name="input_description"></a> [description](#input\_description) | Descrição da versão da layer (até 256 caracteres). | `string` | `null` | no |
| <a name="input_filename"></a> [filename](#input\_filename) | Caminho local do pacote .zip da layer. Use exatamente uma origem: filename ou s3\_object. | `string` | `null` | no |
| <a name="input_license_info"></a> [license\_info](#input\_license\_info) | Licença do software da layer (até 512 caracteres): identificador SPDX (ex.: MIT), URL da licença ou o texto completo. | `string` | `null` | no |
| <a name="input_s3_object"></a> [s3\_object](#input\_s3\_object) | Pacote .zip da layer no S3. Use exatamente uma origem: filename ou s3\_object.<br/>- bucket: nome do bucket (na mesma região da layer).<br/>- key: chave do objeto.<br/>- version: versão do objeto (recomendado em bucket versionado: uma nova versão gera nova versão da layer). | <pre>object({<br/>    bucket  = string<br/>    key     = string<br/>    version = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_skip_destroy"></a> [skip\_destroy](#input\_skip\_destroy) | Mantém as versões anteriores da layer na AWS quando uma nova é publicada ou o recurso é destruído. Com false (padrão), a versão anterior é apagada: funções já implantadas continuam funcionando, mas novos deploys não conseguem usar o ARN antigo. Com true, versões ficam órfãs fora do Terraform e geram custo. | `bool` | `false` | no |
| <a name="input_source_code_hash"></a> [source\_code\_hash](#input\_source\_code\_hash) | Hash SHA256 em base64 do pacote (ex.: filebase64sha256("layer.zip")). Quando muda, uma nova versão da layer é publicada. | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | ARN da versão da layer (com o número da versão). É o valor usado em layers de aws\_lambda\_function. |
| <a name="output_code_sha256"></a> [code\_sha256](#output\_code\_sha256) | SHA256 em base64 do pacote publicado, calculado pela AWS. |
| <a name="output_layer_arn"></a> [layer\_arn](#output\_layer\_arn) | ARN da layer sem a versão. |
| <a name="output_layer_name"></a> [layer\_name](#output\_layer\_name) | Nome da layer. |
| <a name="output_version"></a> [version](#output\_version) | Número da versão publicada da layer. |
<!-- END_TF_DOCS -->
