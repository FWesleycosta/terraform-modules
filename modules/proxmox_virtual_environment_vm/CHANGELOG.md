# Changelog - proxmox_virtual_environment_vm

Todas as mudanças relevantes deste módulo são documentadas aqui.

O formato segue o [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e o módulo usa [Versionamento Semântico](https://semver.org/lang/pt-BR/), com tags `proxmox_virtual_environment_vm/vX.Y.Z`.

## [Não publicado]

## [0.1.0] - 2026-11-24

### Adicionado

- VM no Proxmox VE por clone completo de um template com cloud-init (`template_vm_id`), com nome validado como hostname (`name`) e ID a partir de 100 (`vm_id`).
- CPU do tipo `host` (`cores`), memória dedicada (`memory_mb`), um disco `scsi0` com discard e SSD (`disk_size_gb`, `datastore_id`) e uma placa de rede virtio (`network_bridge`).
- Rede por cloud-init com DHCP por padrão ou IPv4 fixo (`ipv4_address`, `ip_config_gateway`), com validação de que o gateway acompanha o IP fixo.
- DNS próprio opcional (`dns_domain`, `dns_servers`); sem eles, a VM herda o DNS do host.
- Usuário do cloud-init (`account_username`) com pelo menos uma chave SSH pública obrigatória (`ssh_public_keys`).
- QEMU guest agent opcional (`agent_enabled`) e tags simples da VM (`tags`).
- Outputs `id`, `name`, `node_name`, `ipv4_address`, `ipv4_addresses` e `mac_addresses`.
- Requer Terraform `>= 1.9` e provider `bpg/proxmox` `>= 0.123, < 1.0`.
