# Módulo proxmox_virtual_environment_vm

Cria uma VM no Proxmox VE clonando um template com cloud-init:

- **Clone completo** do template (`template_vm_id`): a VM não depende do disco do template depois de criada.
- **CPU** do tipo `host`, com `cores` vCPUs (padrão 2), e **memória** dedicada de `memory_mb` (padrão 2048 MB), sem ballooning.
- **Um disco** `scsi0` de `disk_size_gb` (padrão 20 GB) no `datastore_id` (padrão `local-lvm`), com discard e emulação de SSD ligados.
- **Uma placa de rede** virtio na `network_bridge` (padrão `vmbr0`).
- **Rede por cloud-init**: IP por DHCP por padrão, ou IPv4 fixo com `ipv4_address` e `ip_config_gateway`. DNS herdado do host, a menos que `dns_domain` ou `dns_servers` sejam informados.
- **Acesso por chave SSH**: o cloud-init cria o usuário `account_username` (padrão `ubuntu`) com as chaves de `ssh_public_keys`. Pelo menos uma chave é obrigatória. O módulo não define senha, então não há login por senha no console.
- A VM sobe ao ser criada e liga junto com o host (`started` e `on_boot` fixos em `true`).
- QEMU guest agent desligado por padrão (`agent_enabled`).

Fora do escopo: mais de um disco ou placa de rede, IPv6, VLAN, senha do usuário, user-data próprio no cloud-init, pools, HA e o próprio template. Tipo de CPU, barramento do disco, modelo da placa de rede, `started` e `on_boot` são fixos, sem variável.

## Requisitos do template

- A imagem do template precisa ter o pacote cloud-init instalado. O drive de cloud-init é criado pelo módulo, no mesmo `datastore_id` do disco, e é por ele que a VM recebe rede, usuário e chaves.
- O disco do sistema do template precisa estar em `scsi0`, que é o disco que o módulo redimensiona. Outro barramento, como `virtio0`, não é suportado nesta versão.
- Com `agent_enabled = true`, a imagem do template precisa ter o `qemu-guest-agent` instalado e ativo. Sem ele, o `apply` fica esperando o agente responder.
- O disco do template não pode ser maior que `disk_size_gb`, porque o Proxmox não encolhe o disco do clone.

## Uso

O módulo usa o provider `bpg/proxmox`, configurado no módulo raiz que consome:

```hcl
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.123, < 1.0"
    }
  }
}

provider "proxmox" {
  endpoint = "https://pve.lab.internal:8006/"
  insecure = true # só com certificado autoassinado
}
```

O token da API vem do ambiente, nunca de variável nem de `.tfvars`. O formato é `<usuário>@<realm>!<id do token>=<segredo>`:

```bash
export PROXMOX_VE_API_TOKEN="usuario@pve!token=uuid"
```

O token precisa destes privilégios no Proxmox, testados com os dois exemplos (`apply` e `destroy`) num token com `privsep 1`:

```bash
pveum role add TerraformVM --privs "VM.Clone,VM.Allocate,VM.Audit,VM.Config.CPU,VM.Config.Memory,VM.Config.Disk,VM.Config.Network,VM.Config.Cloudinit,VM.Config.CDROM,VM.Config.Options,VM.Config.HWType,VM.PowerMgmt,VM.GuestAgent.Audit,Datastore.AllocateSpace,Datastore.Audit,SDN.Use,Sys.Audit"
pveum acl modify / --tokens 'usuario@pve!token' --roles TerraformVM
```

O `VM.GuestAgent.Audit` só é usado com `agent_enabled = true`; no Proxmox VE 8, o privilégio equivalente é o `VM.Monitor`. Com `privsep 1`, o token fica com a interseção entre as permissões dele e as do usuário, então o usuário também precisa desses privilégios.

VM com os padrões e IP por DHCP:

```hcl
module "proxmox_virtual_environment_vm" {
  source = "git::ssh://git@github.com/FWesleycosta/terraform-modules.git//modules/proxmox_virtual_environment_vm?ref=proxmox_virtual_environment_vm/v0.1.0"

  name            = "app01"
  vm_id           = 120
  node_name       = "pve"
  template_vm_id  = 9000
  ssh_public_keys = [file("~/.ssh/id_ed25519.pub")]
}
```

Várias VMs com IP fixo, DNS próprio e guest agent:

```hcl
locals {
  vms = {
    "k8s-cp1"     = { vm_id = 210, ipv4_address = "10.20.0.21/24", memory_mb = 4096 }
    "k8s-worker1" = { vm_id = 211, ipv4_address = "10.20.0.22/24", memory_mb = 3072 }
  }
}

module "proxmox_virtual_environment_vm" {
  source   = "git::ssh://git@github.com/FWesleycosta/terraform-modules.git//modules/proxmox_virtual_environment_vm?ref=proxmox_virtual_environment_vm/v0.1.0"
  for_each = local.vms

  name           = each.key
  vm_id          = each.value.vm_id
  node_name      = "pve"
  template_vm_id = 9000

  memory_mb    = each.value.memory_mb
  disk_size_gb = 30

  network_bridge    = "vmbr1"
  ipv4_address      = each.value.ipv4_address
  ip_config_gateway = "10.20.0.1"
  dns_domain        = "lab.internal"
  dns_servers       = ["10.20.0.1"]

  ssh_public_keys = [file("~/.ssh/id_ed25519.pub")]
  agent_enabled   = true

  tags = ["terraform", "k8s"]
}
```

Use `for_each` com um mapa, e não `count`: a chave do mapa mantém a identidade de cada VM quando outra sai da lista.

Veja também [`examples/basico`](examples/basico) e [`examples/completo`](examples/completo).

## Observações

- `ipv4_address` e `ip_config_gateway` andam juntos: com IP fixo, o gateway é obrigatório; com DHCP (`ipv4_address = null`), o gateway precisa ficar `null`.
- `vm_id` e `template_vm_id` começam em 100, porque o Proxmox reserva os IDs abaixo disso.
- `name` vira também o hostname do convidado, por isso segue as regras de hostname: minúsculas, números e hífens, até 63 caracteres, sem começar nem terminar com hífen.
- O output `ipv4_address` devolve o IP fixo configurado (ou `null` com DHCP). O IP real que a VM recebeu só aparece em `ipv4_addresses`, que depende do guest agent e fica vazio com `agent_enabled = false`. Com DHCP e o agente desligado, o Terraform não sabe o IP da VM: use o `mac_addresses` para achá-lo no servidor DHCP, ou ligue o agente.
- A CPU do tipo `host` expõe ao convidado todas as instruções da CPU física, o que pode impedir a migração da VM para um nó com CPU diferente.
- O Proxmox só aceita tags simples, sem `chave=valor`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | >= 0.123, < 1.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | >= 0.123, < 1.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [proxmox_virtual_environment_vm.this](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_name"></a> [name](#input\_name) | Nome da VM e hostname do convidado. Até 63 caracteres: minúsculas, números e hífens, sem começar nem terminar com hífen. | `string` | n/a | yes |
| <a name="input_node_name"></a> [node\_name](#input\_node\_name) | Nó do Proxmox que hospeda a VM. | `string` | n/a | yes |
| <a name="input_ssh_public_keys"></a> [ssh\_public\_keys](#input\_ssh\_public\_keys) | Chaves SSH públicas autorizadas para o usuário do cloud-init. | `list(string)` | n/a | yes |
| <a name="input_template_vm_id"></a> [template\_vm\_id](#input\_template\_vm\_id) | ID do template que será clonado (clone completo). O template precisa ter cloud-init. | `number` | n/a | yes |
| <a name="input_vm_id"></a> [vm\_id](#input\_vm\_id) | ID da VM no Proxmox. | `number` | n/a | yes |
| <a name="input_account_username"></a> [account\_username](#input\_account\_username) | Usuário criado pelo cloud-init na VM. | `string` | `"ubuntu"` | no |
| <a name="input_agent_enabled"></a> [agent\_enabled](#input\_agent\_enabled) | Liga o QEMU guest agent. Só use true se a imagem do template tiver o qemu-guest-agent instalado, senão o Terraform fica esperando o agente responder. | `bool` | `false` | no |
| <a name="input_cores"></a> [cores](#input\_cores) | Quantidade de vCPUs. | `number` | `2` | no |
| <a name="input_datastore_id"></a> [datastore\_id](#input\_datastore\_id) | Datastore do Proxmox onde fica o disco da VM. | `string` | `"local-lvm"` | no |
| <a name="input_disk_size_gb"></a> [disk\_size\_gb](#input\_disk\_size\_gb) | Tamanho do disco em GB. Não pode ser menor que o disco do template, porque o Proxmox não encolhe o disco do clone. | `number` | `20` | no |
| <a name="input_dns_domain"></a> [dns\_domain](#input\_dns\_domain) | Domínio DNS da VM. Com null, herda o do host Proxmox. | `string` | `null` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | Servidores DNS da VM. Com null, herda os do host Proxmox. | `list(string)` | `null` | no |
| <a name="input_ip_config_gateway"></a> [ip\_config\_gateway](#input\_ip\_config\_gateway) | Gateway IPv4 da VM. Obrigatório quando ipv4\_address é fixo; com DHCP, deixe null. | `string` | `null` | no |
| <a name="input_ipv4_address"></a> [ipv4\_address](#input\_ipv4\_address) | Endereço IPv4 fixo com o prefixo (ex.: 10.20.0.21/24). Com null, a VM pega o IP por DHCP. | `string` | `null` | no |
| <a name="input_memory_mb"></a> [memory\_mb](#input\_memory\_mb) | Memória em MB. | `number` | `2048` | no |
| <a name="input_network_bridge"></a> [network\_bridge](#input\_network\_bridge) | Bridge do Proxmox ligada à placa de rede da VM. | `string` | `"vmbr0"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags da VM no Proxmox. O Proxmox só aceita tags simples (sem chave=valor). | `list(string)` | <pre>[<br/>  "terraform"<br/>]</pre> | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_id"></a> [id](#output\_id) | ID da VM no Proxmox (o mesmo valor de vm\_id). |
| <a name="output_ipv4_address"></a> [ipv4\_address](#output\_ipv4\_address) | Endereço IPv4 fixo configurado no cloud-init, em notação CIDR, ou null quando a VM usa DHCP. |
| <a name="output_ipv4_addresses"></a> [ipv4\_addresses](#output\_ipv4\_addresses) | Endereços IPv4 informados pelo QEMU guest agent, uma lista por interface. Fica vazio quando agent\_enabled é false. |
| <a name="output_mac_addresses"></a> [mac\_addresses](#output\_mac\_addresses) | Endereços MAC das interfaces de rede, na ordem dos network\_device. |
| <a name="output_name"></a> [name](#output\_name) | Nome da VM. |
| <a name="output_node_name"></a> [node\_name](#output\_node\_name) | Nó do Proxmox onde a VM está. |
<!-- END_TF_DOCS -->
